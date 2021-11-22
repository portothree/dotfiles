function isEditable(element) {
	const elNodeName = element.nodeName.toLowerCase();
	const isTextarea = elNodeName == 'textarea';
	const isInput = elNodeName == 'input' && element.type == 'text';

	return (
		document.designMode == 'on' ||
		element.contentEditable == 'true' ||
		isTextArea ||
		isInput
	);
}

function vimNavigation() {
	const directions = {
		up: { cmd: () => window.scrollByLines(0, -4) },
		down: { cmd: () => window.scrollByLines(0, 4) },
		left: { cmd: () => window.scrollBy(-30, 0) },
		right: { cmd: () => window.scrollBy(30, 0) },
		top: { cmd: () => window.scroll(0, 0) },
		bottom: {
			cmd: () => window.scroll(document.width, document.height),
		},
	};

	const bindings = {
		k: directions.up,
		j: directions.down,
		h: directions.left,
		l: directions.right,
		gg: directions.top,
		G: directions.bottom,
	};

	window.addEventListener(
		'keypress',
		function (evt) {
			const target = evt.target;

			// Ignore keypresses on a editable element
			if (isEditable(target)) {
				return;
			}

			const key = String.fromCharCode(evt.charCode);

			const direction = bindings[key];
			direction.cmd();
		},
		false
	);
}

vimNavigation();
