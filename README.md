# Modifaxe/JSON
Adds support for the .json format in [Modifaxe](https://github.com/SomeRanDev/modifaxe).

&nbsp;
&nbsp;

## Installation
First install Modifaxe/JSON:
```hxml
# install haxelib release
haxelib install modifaxe.json
```

Next add the library to your .hxml or compile command:
```
-lib modifaxe
```

Finally, you can set Modifaxe's default format to .json:
```haxe
-D modifaxe_default_format=json
```

Alternatively, you can set the format to .json on a metadata basis:
```
@:modifaxe(Format=Json)
function getWindowSize() {
	return 800;
}
```
