package modifaxe_json;

import haxe.macro.Expr;

import modifaxe.Output;
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

					switch(entry.value) {
						// wrap enum identifiers with quotes for json string
						case EEnum(identifier, _): buf.add('"$identifier"');

						// note: `haxe.Json.parse` seems to allow new lines in strings,
						//       so we won't worry about it here...
						case _: buf.add(entry.value.toValueString());
					}
				}

				buf.add("\n\t}");
			}

			buf.add("\n}");

			modifaxe.Output.saveContent(file.getPath(extension), buf.toString());
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

					var valueExpr = macro data.$sectionName.$entryName;
					
					// Wrap with enum loader function if loading enum
					switch(entry.value) {
						case EEnum(_, enumType): {
							final enumLoadIdent = Output.getFunctionForEnumType(enumType);
							if(enumLoadIdent != null) {
								valueExpr = macro ModifaxeLoader.$enumLoadIdent($valueExpr);
							}
						}
						case _:
					}

					// Store expression in list.
					if(valueExpr != null) {
						expressions.push(macro ModifaxeData.$identifier = $valueExpr);
					}
				}
			}

			blockExpressions.push(macro $b{expressions});
		}

		return macro @:mergeBlock $b{blockExpressions};
	}
}
