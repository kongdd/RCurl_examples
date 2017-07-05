// https://gist.github.com/larchanka/7080820/
(function () {
	this.uniqid = function (pr, en) {
		var pr = pr || '', en = en || false, result;
  
		this.seed = function (s, w) {
			s = parseInt(s, 10).toString(16);
			return w < s.length ? s.slice(s.length - w) : (w > s.length) ? new Array(1 + (w - s.length)).join('0') + s : s;
		};

		result = pr + this.seed(parseInt(new Date().getTime() / 1000, 10), 8) + this.seed(Math.floor(Math.random() * 0x75bcd15) + 1, 5);
  
		if (en) result += (Math.random() * 10).toFixed(8).toString();

		return result;
	};
})();