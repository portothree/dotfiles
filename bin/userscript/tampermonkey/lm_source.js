// ==UserScript==
// @name         LunchMoney Transaction Source Indicator
// @namespace    http://tampermonkey.net/
// @version      1.6
// @description  Shows whether a transaction was created via API or manually in LunchMoney
// @author       You
// @match        https://my.lunchmoney.app/*
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_xmlhttpRequest
// @grant        GM_log
// @connect      dev.lunchmoney.app
// @connect      *
// ==/UserScript==

(function() {
    'use strict';

    const STORAGE_KEY = 'lm_api_key';
    const CACHE_KEY = 'lm_transactions_cache';
    const CACHE_EXPIRY = 5 * 60 * 1000; // 5 minutes
    let interceptedDateRange = null; // Store date range from intercepted requests
    let interceptRefreshTimeout = null; // Debounce timeout for refresh after intercept

    // Source badge styles
    const styles = `
        .lm-source-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            white-space: nowrap;
        }
        .lm-source-badge.api {
            background-color: #2185d0;
            color: white;
        }
        .lm-source-badge.manual {
            background-color: #21ba45;
            color: white;
        }
        .lm-source-badge.plaid {
            background-color: #a333c8;
            color: white;
        }
        .lm-source-badge.csv {
            background-color: #f2711c;
            color: white;
        }
        .lm-source-badge.unknown {
            background-color: #767676;
            color: white;
        }
        .lm-source-cell {
            width: 70px !important;
            min-width: 70px !important;
            text-align: center !important;
            padding: 4px !important;
        }
        th.lm-source-header {
            width: 70px !important;
            min-width: 70px !important;
            text-align: center !important;
        }
        .lm-api-key-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.7);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 10000;
        }
        .lm-api-key-modal-content {
            background: #1b1c1d;
            padding: 24px;
            border-radius: 8px;
            max-width: 450px;
            width: 90%;
            color: #fff;
        }
        .lm-api-key-modal h3 {
            margin: 0 0 16px 0;
            color: #fff;
        }
        .lm-api-key-modal input {
            width: 100%;
            padding: 10px;
            border: 1px solid #444;
            border-radius: 4px;
            margin-bottom: 16px;
            background: #2d2d2d;
            color: #fff;
            box-sizing: border-box;
        }
        .lm-api-key-modal button {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 8px;
        }
        .lm-api-key-modal .btn-save {
            background: #f5a623;
            color: #000;
        }
        .lm-api-key-modal .btn-cancel {
            background: #444;
            color: #fff;
        }
        .lm-settings-btn {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: #f5a623;
            color: #000;
            border: none;
            padding: 8px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            z-index: 9999;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .lm-settings-btn:hover {
            background: #e09600;
        }
    `;

    // Inject styles
    function injectStyles() {
        const styleEl = document.createElement('style');
        styleEl.textContent = styles;
        document.head.appendChild(styleEl);
    }

    // Handle intercepted date range update with debouncing
    function handleInterceptedDateRange(startDate, endDate) {
        const newRange = { startDate, endDate };
        const rangeChanged = !interceptedDateRange ||
            interceptedDateRange.startDate !== startDate ||
            interceptedDateRange.endDate !== endDate;

        interceptedDateRange = newRange;

        if (rangeChanged) {
            console.log('[LM Source] Date range changed, will refresh...');
            // Clear cache for new date range
            GM_setValue(CACHE_KEY, null);

            // Debounce the refresh
            clearTimeout(interceptRefreshTimeout);
            interceptRefreshTimeout = setTimeout(() => {
                if (isTransactionsPage()) {
                    activateOnTransactionsPage();
                }
            }, 1500); // Wait 1.5s for LunchMoney to finish loading
        }
    }

    // Intercept XHR requests to capture date range from LunchMoney's own API calls
    function setupRequestInterceptor() {
        // Intercept XMLHttpRequest
        const originalXHROpen = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function(method, url, ...args) {
            if (url && url.includes('/transactions') && url.includes('start_date')) {
                try {
                    const urlObj = new URL(url, window.location.origin);
                    const startDate = urlObj.searchParams.get('start_date');
                    const endDate = urlObj.searchParams.get('end_date');
                    if (startDate && endDate) {
                        console.log('[LM Source] Intercepted XHR date range:', startDate, 'to', endDate);
                        handleInterceptedDateRange(startDate, endDate);
                    }
                } catch (e) {
                    console.log('[LM Source] Error parsing XHR URL:', e);
                }
            }
            return originalXHROpen.call(this, method, url, ...args);
        };

        // Intercept fetch
        const originalFetch = window.fetch;
        window.fetch = function(url, ...args) {
            const urlStr = typeof url === 'string' ? url : url?.url;
            if (urlStr && urlStr.includes('/transactions') && urlStr.includes('start_date')) {
                try {
                    const urlObj = new URL(urlStr, window.location.origin);
                    const startDate = urlObj.searchParams.get('start_date');
                    const endDate = urlObj.searchParams.get('end_date');
                    if (startDate && endDate) {
                        console.log('[LM Source] Intercepted fetch date range:', startDate, 'to', endDate);
                        handleInterceptedDateRange(startDate, endDate);
                    }
                } catch (e) {
                    console.log('[LM Source] Error parsing fetch URL:', e);
                }
            }
            return originalFetch.call(this, url, ...args);
        };

        console.log('[LM Source] Request interceptor set up');
    }

    // Get date range - prefer intercepted range, fall back to URL
    function getDateRange() {
        // First, check if we have an intercepted date range
        if (interceptedDateRange) {
            console.log('[LM Source] Using intercepted date range:', interceptedDateRange);
            return interceptedDateRange;
        }

        // Fall back to URL-based date range
        const match = window.location.pathname.match(/\/transactions\/(\d{4})\/(\d{1,2})/);
        if (match) {
            const year = parseInt(match[1]);
            const month = parseInt(match[2]);
            const startDate = `${year}-${String(month).padStart(2, '0')}-01`;
            const lastDay = new Date(year, month, 0).getDate();
            const endDate = `${year}-${String(month).padStart(2, '0')}-${lastDay}`;
            console.log('[LM Source] Using URL-based date range:', startDate, 'to', endDate);
            return { startDate, endDate };
        }
        return null;
    }

    // Show API key modal
    function showApiKeyModal(existingKey = '') {
        return new Promise((resolve) => {
            const modal = document.createElement('div');
            modal.className = 'lm-api-key-modal';
            modal.innerHTML = `
                <div class="lm-api-key-modal-content">
                    <h3>LunchMoney API Key</h3>
                    <p style="margin-bottom: 16px; color: #aaa; font-size: 14px;">
                        Enter your LunchMoney API key to fetch transaction sources.
                        <br><br>
                        Get your API key from: <a href="https://my.lunchmoney.app/developers" target="_blank" style="color: #f5a623;">Settings > Developers</a>
                    </p>
                    <input type="password" id="lm-api-key-input" placeholder="Enter your API key" value="${existingKey}">
                    <div>
                        <button class="btn-save">Save</button>
                        <button class="btn-cancel">Cancel</button>
                    </div>
                </div>
            `;

            document.body.appendChild(modal);

            const input = modal.querySelector('#lm-api-key-input');
            const saveBtn = modal.querySelector('.btn-save');
            const cancelBtn = modal.querySelector('.btn-cancel');

            saveBtn.addEventListener('click', () => {
                const key = input.value.trim();
                if (key) {
                    GM_setValue(STORAGE_KEY, key);
                    modal.remove();
                    resolve(key);
                }
            });

            cancelBtn.addEventListener('click', () => {
                modal.remove();
                resolve(null);
            });

            input.focus();
        });
    }

    // Update button status
    function updateButtonStatus(status) {
        const btn = document.querySelector('.lm-settings-btn');
        if (btn) {
            const statusMap = {
                'loading': '&#8987; Loading...',
                'ready': '&#9881; Source Indicator',
                'error': '&#9888; Error - Click to retry',
                'done': '&#10003; Sources Loaded'
            };
            btn.innerHTML = statusMap[status] || statusMap['ready'];
        }
    }

    // Add settings button
    function addSettingsButton() {
        const existingBtn = document.querySelector('.lm-settings-btn');
        if (existingBtn) return;

        const btn = document.createElement('button');
        btn.className = 'lm-settings-btn';
        btn.innerHTML = '&#9881; Source Indicator';
        btn.addEventListener('click', async () => {
            const currentKey = GM_getValue(STORAGE_KEY, '');
            const newKey = await showApiKeyModal(currentKey);
            if (newKey) {
                // Clear cache and refetch
                GM_setValue(CACHE_KEY, null);
                console.log('[LM Source] API key updated, refetching...');
                fetchAndDisplaySources();
            }
        });
        document.body.appendChild(btn);
    }

    // Fetch transactions from API
    function fetchTransactions(apiKey, startDate, endDate) {
        const url = `https://dev.lunchmoney.app/v1/transactions?start_date=${startDate}&end_date=${endDate}`;
        console.log('[LM Source] Fetching:', url);

        return new Promise((resolve, reject) => {
            GM_xmlhttpRequest({
                method: 'GET',
                url: url,
                headers: {
                    'Authorization': `Bearer ${apiKey}`,
                    'Content-Type': 'application/json'
                },
                onload: function(response) {
                    console.log('[LM Source] Response status:', response.status);
                    console.log('[LM Source] Response:', response.responseText.substring(0, 500));

                    if (response.status === 200) {
                        try {
                            const data = JSON.parse(response.responseText);
                            console.log('[LM Source] Parsed transactions:', data.transactions?.length || 0);
                            resolve(data.transactions || []);
                        } catch (e) {
                            console.error('[LM Source] Parse error:', e);
                            reject(new Error('Failed to parse response'));
                        }
                    } else if (response.status === 401) {
                        reject(new Error('Invalid API key'));
                    } else {
                        reject(new Error(`API error: ${response.status}`));
                    }
                },
                onerror: function(error) {
                    console.error('[LM Source] Network error:', error);
                    reject(new Error('Network error'));
                }
            });
        });
    }

    // Extract transaction ID from a row
    function extractTransactionId(row) {
        // Try to find ID from the price element
        const priceEl = row.querySelector('[id^="transaction-price-"]');
        if (priceEl) {
            const match = priceEl.id.match(/transaction-price-(\d+)/);
            if (match) return match[1];
        }
        return null;
    }

    // Create source badge
    function createSourceBadge(source) {
        const badge = document.createElement('span');
        const normalizedSource = (source || 'unknown').toLowerCase();
        badge.className = `lm-source-badge ${normalizedSource}`;

        const sourceLabels = {
            'api': 'API',
            'manual': 'Manual',
            'plaid': 'Plaid',
            'csv': 'CSV',
            'unknown': '?'
        };

        // Use short labels for the column view
        badge.textContent = sourceLabels[normalizedSource] || source || '?';
        badge.title = `Source: ${source || 'Unknown'}`;

        return badge;
    }

    // Add source column header to the table
    function addSourceColumnHeader() {
        const headerRow = document.querySelector('table.p-transactions-table thead tr');
        if (!headerRow || headerRow.querySelector('.lm-source-header')) return;

        // Find the Date header (first column after checkbox and td-resize)
        const headers = headerRow.querySelectorAll('th');
        let dateHeaderIndex = -1;

        headers.forEach((th, i) => {
            if (th.textContent.includes('Date')) {
                dateHeaderIndex = i;
            }
        });

        if (dateHeaderIndex === -1) {
            console.log('[LM Source] Could not find Date header');
            return;
        }

        // Create new header cell
        const sourceHeader = document.createElement('th');
        sourceHeader.className = 'lm-source-header';
        sourceHeader.innerHTML = '<div>Source</div>';

        // Insert before the Date header
        const dateHeader = headers[dateHeaderIndex];
        headerRow.insertBefore(sourceHeader, dateHeader);

        // Add a td-resize after our header for consistency
        const resizer = document.createElement('th');
        resizer.className = 'td-resize';
        sourceHeader.insertAdjacentElement('afterend', resizer);

        console.log('[LM Source] Added source column header before Date');
    }

    // Add empty source cell to editing rows (new transaction form)
    function addSourceCellToEditingRows() {
        const editingRows = document.querySelectorAll('tr.editing');

        editingRows.forEach(row => {
            // Skip if already has source cell
            if (row.querySelector('.lm-source-cell')) return;

            const cells = row.querySelectorAll('td');
            if (cells.length < 3) return;

            // Find the cell with the datepicker (it's the date cell that needs to shift)
            let dateCellIndex = -1;
            cells.forEach((td, i) => {
                if (td.querySelector('.react-datepicker-wrapper') || td.querySelector('.datepicker')) {
                    dateCellIndex = i;
                }
            });

            if (dateCellIndex === -1) {
                // Fallback: usually after checkbox (0) and td-divider (1)
                dateCellIndex = 2;
            }

            // Create empty source cell for new transactions
            const sourceCell = document.createElement('td');
            sourceCell.className = 'lm-source-cell';
            sourceCell.innerHTML = '<span class="lm-source-badge manual" style="opacity: 0.5;">New</span>';

            // Insert before date cell
            if (cells[dateCellIndex]) {
                row.insertBefore(sourceCell, cells[dateCellIndex]);

                // Add a td-divider after our cell
                const divider = document.createElement('td');
                divider.className = 'td-divider';
                sourceCell.insertAdjacentElement('afterend', divider);
            }
        });
    }

    // Apply source badges to transaction rows
    function applySourceBadges(transactionsMap) {
        // First, add the header column
        addSourceColumnHeader();

        // Handle editing rows (new transaction form)
        addSourceCellToEditingRows();

        const rows = document.querySelectorAll('tr.transaction-row');
        console.log('[LM Source] Found transaction rows:', rows.length);
        console.log('[LM Source] Transaction map size:', Object.keys(transactionsMap).length);

        let appliedCount = 0;
        rows.forEach((row, index) => {
            // Skip if already processed
            if (row.querySelector('.lm-source-cell')) return;

            const txId = extractTransactionId(row);
            if (!txId) {
                console.log('[LM Source] Could not extract ID for row', index);
                return;
            }

            const transaction = transactionsMap[txId];
            const source = transaction ? transaction.source : null;

            // Find the date cell (contains a date like 2025-12-18)
            const cells = row.querySelectorAll('td');
            let dateCellIndex = -1;

            cells.forEach((td, i) => {
                const text = td.textContent?.trim();
                if (text && text.match(/^\d{4}-\d{2}-\d{2}$/)) {
                    dateCellIndex = i;
                }
            });

            if (dateCellIndex === -1) {
                // Fallback: date is usually the 3rd cell (after checkbox and td-divider)
                dateCellIndex = 2;
            }

            // Create source cell
            const sourceCell = document.createElement('td');
            sourceCell.className = 'lm-source-cell';

            if (source) {
                const badge = createSourceBadge(source);
                sourceCell.appendChild(badge);
            } else {
                sourceCell.innerHTML = '<span class="lm-source-badge unknown">?</span>';
            }

            // Insert before date cell
            if (dateCellIndex !== -1 && cells[dateCellIndex]) {
                const dateCell = cells[dateCellIndex];
                row.insertBefore(sourceCell, dateCell);
                appliedCount++;

                // Add a td-divider after our cell for consistency
                const divider = document.createElement('td');
                divider.className = 'td-divider';
                sourceCell.insertAdjacentElement('afterend', divider);
            }
        });

        console.log('[LM Source] Applied badges to', appliedCount, 'rows');
    }

    // Main function to fetch and display sources
    async function fetchAndDisplaySources() {
        console.log('[LM Source] fetchAndDisplaySources called');

        let apiKey = GM_getValue(STORAGE_KEY, '');
        console.log('[LM Source] API key exists:', !!apiKey, 'length:', apiKey?.length);

        if (!apiKey) {
            console.log('[LM Source] No API key, showing modal...');
            apiKey = await showApiKeyModal();
            if (!apiKey) {
                console.log('[LM Source] User cancelled API key input');
                return;
            }
        }

        const dateRange = getDateRange();
        console.log('[LM Source] Date range:', dateRange);

        if (!dateRange) {
            console.log('[LM Source] Could not determine date range');
            return;
        }

        // Check cache
        const cacheData = GM_getValue(CACHE_KEY, null);
        const cacheKey = `${dateRange.startDate}_${dateRange.endDate}`;

        let transactions;

        if (cacheData && cacheData.key === cacheKey && (Date.now() - cacheData.timestamp) < CACHE_EXPIRY) {
            console.log('[LM Source] Using cached transactions');
            transactions = cacheData.transactions;
        } else {
            try {
                updateButtonStatus('loading');
                console.log('[LM Source] Fetching transactions from API...');
                transactions = await fetchTransactions(apiKey, dateRange.startDate, dateRange.endDate);

                // Cache the results
                GM_setValue(CACHE_KEY, {
                    key: cacheKey,
                    timestamp: Date.now(),
                    transactions: transactions
                });
            } catch (error) {
                console.error('[LM Source]', error.message);
                updateButtonStatus('error');
                if (error.message === 'Invalid API key') {
                    GM_setValue(STORAGE_KEY, '');
                    const newKey = await showApiKeyModal();
                    if (newKey) {
                        fetchAndDisplaySources();
                    }
                }
                return;
            }
        }

        // Create a map of transactions by ID for quick lookup
        const transactionsMap = {};
        transactions.forEach(tx => {
            transactionsMap[tx.id] = tx;
        });

        console.log(`[LM Source] Loaded ${transactions.length} transactions`);

        // Apply badges
        applySourceBadges(transactionsMap);
        updateButtonStatus('done');
    }

    // Observe for dynamic content changes
    function observeTransactionChanges() {
        const observer = new MutationObserver((mutations) => {
            let shouldUpdate = false;
            let hasEditingRow = false;

            for (const mutation of mutations) {
                if (mutation.type === 'childList') {
                    for (const node of mutation.addedNodes) {
                        if (node.nodeType === 1) {
                            if (node.classList?.contains('transaction-row') ||
                                node.querySelector?.('.transaction-row')) {
                                shouldUpdate = true;
                            }
                            if (node.classList?.contains('editing') ||
                                node.querySelector?.('.editing')) {
                                hasEditingRow = true;
                            }
                        }
                    }
                }
                if (shouldUpdate && hasEditingRow) break;
            }

            // Handle editing rows immediately (no debounce needed)
            if (hasEditingRow) {
                setTimeout(() => {
                    addSourceColumnHeader();
                    addSourceCellToEditingRows();
                }, 50);
            }

            if (shouldUpdate) {
                // Debounce updates for transaction rows
                clearTimeout(window._lmSourceTimeout);
                window._lmSourceTimeout = setTimeout(() => {
                    const cacheData = GM_getValue(CACHE_KEY, null);
                    if (cacheData && cacheData.transactions) {
                        const transactionsMap = {};
                        cacheData.transactions.forEach(tx => {
                            transactionsMap[tx.id] = tx;
                        });
                        applySourceBadges(transactionsMap);
                    }
                }, 100);
            }
        });

        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
    }

    // Check if we're on a transactions page
    function isTransactionsPage() {
        return window.location.pathname.match(/\/transactions(\/|$)/);
    }

    // Show/hide the settings button based on current page
    function updateSettingsButtonVisibility() {
        const btn = document.querySelector('.lm-settings-btn');
        if (btn) {
            btn.style.display = isTransactionsPage() ? 'flex' : 'none';
        }
    }

    // Activate on transactions page
    function activateOnTransactionsPage() {
        if (!isTransactionsPage()) {
            console.log('[LM Source] Not on transactions page, skipping activation');
            updateSettingsButtonVisibility();
            return;
        }

        console.log('[LM Source] On transactions page, activating...');
        updateSettingsButtonVisibility();

        // Wait for the transactions table to appear
        function waitForTable() {
            const table = document.querySelector('table.p-transactions-table');
            if (table) {
                console.log('[LM Source] Found transactions table, starting fetch...');
                fetchAndDisplaySources();
            } else {
                console.log('[LM Source] Waiting for table...');
                setTimeout(waitForTable, 500);
            }
        }

        waitForTable();
    }

    // Handle URL changes (SPA navigation)
    function handleNavigation() {
        let lastPath = window.location.pathname;
        let lastDatePath = '';

        const checkPath = () => {
            const currentPath = window.location.pathname;

            if (currentPath !== lastPath) {
                console.log('[LM Source] Path changed:', lastPath, '->', currentPath);
                lastPath = currentPath;

                if (isTransactionsPage()) {
                    // Extract date portion for cache invalidation
                    const dateMatch = currentPath.match(/\/transactions\/(\d{4}\/\d{1,2})/);
                    const currentDatePath = dateMatch ? dateMatch[1] : '';

                    if (currentDatePath !== lastDatePath) {
                        // Different month, clear cache
                        console.log('[LM Source] Month changed, clearing cache');
                        GM_setValue(CACHE_KEY, null);
                        lastDatePath = currentDatePath;
                    }

                    // Small delay to let the page render
                    setTimeout(activateOnTransactionsPage, 300);
                } else {
                    updateSettingsButtonVisibility();
                }
            }
        };

        // Check periodically for SPA navigation
        setInterval(checkPath, 500);

        // Also listen for popstate (browser back/forward)
        window.addEventListener('popstate', () => {
            setTimeout(checkPath, 100);
        });
    }

    // Initialize
    function init() {
        console.log('[LM Source] Initializing on:', window.location.pathname);

        // Set up request interceptor first to capture date ranges
        setupRequestInterceptor();

        injectStyles();
        addSettingsButton();
        updateSettingsButtonVisibility();

        // Only activate if we're already on transactions page
        if (isTransactionsPage()) {
            // Wait for the page to fully load
            if (document.readyState === 'complete') {
                activateOnTransactionsPage();
            } else {
                window.addEventListener('load', activateOnTransactionsPage);
            }
        }

        // Observe for dynamic changes (only runs when needed)
        observeTransactionChanges();

        // Handle SPA navigation
        handleNavigation();
    }

    console.log('[LM Source] Script loaded');
    init();
})();
