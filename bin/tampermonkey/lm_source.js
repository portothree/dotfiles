// ==UserScript==
// @name         LunchMoney Transaction Source Indicator
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Shows whether a transaction was created via API or manually in LunchMoney
// @author       You
// @match        https://my.lunchmoney.app/transactions/*
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_xmlhttpRequest
// @connect      api.lunchmoney.app
// ==/UserScript==

(function() {
    'use strict';

    const STORAGE_KEY = 'lm_api_key';
    const CACHE_KEY = 'lm_transactions_cache';
    const CACHE_EXPIRY = 5 * 60 * 1000; // 5 minutes

    // Source badge styles
    const styles = `
        .lm-source-badge {
            display: inline-flex;
            align-items: center;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
            margin-left: 4px;
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

    // Get date range from URL
    function getDateRangeFromURL() {
        const match = window.location.pathname.match(/\/transactions\/(\d{4})\/(\d{1,2})/);
        if (match) {
            const year = parseInt(match[1]);
            const month = parseInt(match[2]);
            const startDate = `${year}-${String(month).padStart(2, '0')}-01`;
            const lastDay = new Date(year, month, 0).getDate();
            const endDate = `${year}-${String(month).padStart(2, '0')}-${lastDay}`;
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
                fetchAndDisplaySources();
            }
        });
        document.body.appendChild(btn);
    }

    // Fetch transactions from API
    function fetchTransactions(apiKey, startDate, endDate) {
        return new Promise((resolve, reject) => {
            GM_xmlhttpRequest({
                method: 'GET',
                url: `https://dev.lunchmoney.app/v1/transactions?start_date=${startDate}&end_date=${endDate}`,
                headers: {
                    'Authorization': `Bearer ${apiKey}`,
                    'Content-Type': 'application/json'
                },
                onload: function(response) {
                    if (response.status === 200) {
                        try {
                            const data = JSON.parse(response.responseText);
                            resolve(data.transactions || []);
                        } catch (e) {
                            reject(new Error('Failed to parse response'));
                        }
                    } else if (response.status === 401) {
                        reject(new Error('Invalid API key'));
                    } else {
                        reject(new Error(`API error: ${response.status}`));
                    }
                },
                onerror: function(error) {
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
        badge.className = `lm-source-badge ${source || 'unknown'}`;

        const sourceLabels = {
            'api': 'API',
            'manual': 'Manual',
            'plaid': 'Plaid',
            'csv': 'CSV',
            'unknown': '?'
        };

        const sourceIcons = {
            'api': '&#129302;', // robot
            'manual': '&#9997;', // writing hand
            'plaid': '&#128279;', // link
            'csv': '&#128196;', // page
            'unknown': '&#10067;' // question
        };

        badge.innerHTML = `${sourceIcons[source] || sourceIcons.unknown} ${sourceLabels[source] || source || 'Unknown'}`;
        badge.title = `Source: ${source || 'Unknown'}`;

        return badge;
    }

    // Apply source badges to transaction rows
    function applySourceBadges(transactionsMap) {
        const rows = document.querySelectorAll('tr.transaction-row');

        rows.forEach(row => {
            // Skip if already processed
            if (row.querySelector('.lm-source-badge')) return;

            const txId = extractTransactionId(row);
            if (!txId) return;

            const transaction = transactionsMap[txId];
            if (!transaction) return;

            // Find the payee cell to insert the badge
            const payeeCell = row.querySelector('td.editable .g-editable-text .default-state.editable-string');
            if (payeeCell) {
                const badge = createSourceBadge(transaction.source);
                payeeCell.appendChild(badge);
            }
        });
    }

    // Main function to fetch and display sources
    async function fetchAndDisplaySources() {
        let apiKey = GM_getValue(STORAGE_KEY, '');

        if (!apiKey) {
            apiKey = await showApiKeyModal();
            if (!apiKey) return;
        }

        const dateRange = getDateRangeFromURL();
        if (!dateRange) {
            console.log('[LM Source] Could not determine date range from URL');
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
    }

    // Observe for dynamic content changes
    function observeTransactionChanges() {
        const observer = new MutationObserver((mutations) => {
            let shouldUpdate = false;

            for (const mutation of mutations) {
                if (mutation.type === 'childList') {
                    for (const node of mutation.addedNodes) {
                        if (node.nodeType === 1 && (
                            node.classList?.contains('transaction-row') ||
                            node.querySelector?.('.transaction-row')
                        )) {
                            shouldUpdate = true;
                            break;
                        }
                    }
                }
                if (shouldUpdate) break;
            }

            if (shouldUpdate) {
                // Debounce updates
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

    // Handle URL changes (SPA navigation)
    function handleNavigation() {
        let lastPath = window.location.pathname;

        const checkPath = () => {
            if (window.location.pathname !== lastPath) {
                lastPath = window.location.pathname;
                if (lastPath.includes('/transactions/')) {
                    // Clear cache for new month
                    GM_setValue(CACHE_KEY, null);
                    setTimeout(fetchAndDisplaySources, 500);
                }
            }
        };

        // Check periodically for SPA navigation
        setInterval(checkPath, 1000);
    }

    // Initialize
    function init() {
        injectStyles();
        addSettingsButton();

        // Wait for the page to fully load
        if (document.readyState === 'complete') {
            fetchAndDisplaySources();
        } else {
            window.addEventListener('load', fetchAndDisplaySources);
        }

        // Observe for dynamic changes
        observeTransactionChanges();

        // Handle SPA navigation
        handleNavigation();
    }

    init();
})();
