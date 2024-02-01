package modifaxe_json;

import haxe.macro.Expr;

import modifaxe.builder.File;
import modifaxe.format.Format;

/**
	The implementation of the `.json` file format.
**/
class JsonFormat extends Format {
	/**
		The file extension used by this format.
	**/
	static var extension = "json";

	/**
		Generates `.json` files from the provided `File`s.
	**/
	public function saveModFiles(files: Array<File>): Void {
		for(file in files) {
			final buf = new StringBuf();
			buf.add("{\n");

			var firstSection = true;
			for(section in file.sections) {
				if(firstSection) {
					firstSection = false;
				} else {
					buf.add(",\n");
				}
				buf.add("\t\"");
				buf.add(section.name);
				buf.add("\": {\n");
				
				var first = true;
				for(entry in section.entries) {
					if(first) {
						first = false;
					} else {
						buf.add(",\n");
					}
					buf.add("\t\t\"");
					buf.add(entry.name);
					buf.add("\": ");

					// note: `haxe.Json.parse` seems to allow new lines in strings,
					//       so we won't worry about it here...
					buf.add(entry.value.toValueString());
				}

				buf.add("\n\t}");
			}

			buf.add("\n}");

			sys.io.File.saveContent(file.getPath(extension), buf.toString());
		}
	}

	/**
		Generates an expression that loads data from `.json` files.
	**/
	public function generateLoadExpression(files: Array<File>): Expr {
		final blockExpressions = [];

		for(file in files) {
			final expressions = [];

			final path = file.getPath(extension);
			#if macro // fix display error with $v{}
			expressions.push(
				macro final data = haxe.Json.parse(sys.io.File.getContent($v{path}))
			);
			#end

			for(section in file.sections) {
				for(entry in section.entries) {
					final sectionName = section.name;
					final entryName = entry.name;
					final identifier = entry.getUniqueName();

					// Store expression in list.
					expressions.push(macro ModifaxeData.$identifier = data.$sectionName.$entryName);
				}
			}

			blockExpressions.push(macro $b{expressions});
		}

		return macro @:mergeBlock $b{blockExpressions};
	}
}
