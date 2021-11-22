function isEditable(element) {
	const elNodeName = element.nodeName.toLowerCase();

	const checks = [
		elNodeName == 'textarea',
		elNodeName == 'input' && element.type == 'text',
		element.contentEditable == 'true',
		document.designMode == 'on',
	];

	return !!checks.filter((check) => !!check).length;
}

// Vim navigation
(function () {
	const directions = {
		up: { cmd: () => window.scrollBy(0, -48) },
		down: { cmd: () => window.scrollBy(0, 48) },
		left: { cmd: () => window.scrollBy(-30, 0) },
		right: { cmd: () => window.scrollBy(30, 0) },
		top: { cmd: () => window.scroll(0, 0) },
		bottom: {
			cmd: () => window.scroll(0, document.body.scrollHeight),
		},
	};

	const bindings = {
		k: directions.up,
		j: directions.down,
		h: directions.left,
		l: directions.right,
		g: directions.top,
		G: directions.bottom,
	};

	window.addEventListener(
		'keypress',
		function (evt) {
			const target = evt.target;
			const key = String.fromCharCode(evt.charCode);
			const direction = bindings[key];

			// Ignore keypresses on a editable element
			if (isEditable(target)) {
				return;
			}

			if (direction) {
				direction.cmd();
			}
		},
		false
	);
})();
