package modifaxe_json;

import modifaxe.format.Format;

function init() {
	Format.registerFormat("json", new JsonFormat());
}
