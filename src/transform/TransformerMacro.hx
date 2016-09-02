package transform;

import haxe.macro.Expr;
import haxe.macro.Context;
using tink.MacroApi;

class TransformerMacro {
	public static function create(input:Expr, trans:Expr, eq:Expr) {
		var oldVars = [];
		var newVars = [];
		var results = [];
		var checks = [];
		
		eq = eq.ifNull(macro Transformer.eq);
		
		var inputType:haxe.macro.Type = null; // type of the input function
		var inputArgs:Array<FunctionArg> = null;
		
		function handle(i:Int, expr:Expr) {
			// var type = switch Context.typeof(expr).reduce() {
			// 	case TFun([{t: t}], ret): t;
			// 	default: throw 'assert';
			// }
			// 
			// if(stateType == null) stateType = type;
			// else if(stateType.getID() != type.getID()) throw "Different state type";
			
			var oldVarName = '__old$i';
			var newVarName = '__new$i';
			var oldVar = macro $i{oldVarName};
			var newVar = macro $i{newVarName};
			results.push(newVar);
			oldVars.push({name: oldVarName, expr: null, type: null});
			var args = [for(a in inputArgs) macro $i{a.name}];
			newVars.push({name: newVarName, expr: macro $expr($a{args}), type: null});
			checks.push(macro if(!$eq($oldVar, $newVar)) {
				changed = true;
				$oldVar = $newVar;
			});
		}
		
		function extractArgs(type:haxe.macro.Type):Array<FunctionArg> {
			switch type {
				case TFun(args, _): return [for(i in 0...args.length) {
					name: 'a$i',
					type: args[i].t.toComplex(),
				}];
				default: throw 'Expected function';
			}
		}
		
		switch input.expr {
			case EArrayDecl(values):
				for(i in 0...values.length) {
					var type = Context.typeof(values[i]);
					if(inputType == null) {
						inputType = type;
						inputArgs = extractArgs(inputType);
					} else {
						var args = extractArgs(type);
						if(args.length != inputArgs.length) Context.error('Different number of arguments', values[i].pos);
						for(i in 0...args.length) {
							if(!Context.unify(args[i].type.toType().sure(), inputArgs[i].type.toType().sure()))
								Context.error('Incompatible argument type', values[i].pos);
						}
					}
					handle(i, values[i]);
				}
			default:
				inputType = Context.typeof(input);
				inputArgs = extractArgs(inputType);
				handle(0, input);
		}
		
		var resultFunctionType = TFunction([for(a in inputArgs) a.type], switch Context.typeof(trans) {
			case TFun(_, ret): ret.toComplex();
			default: Context.error('Transformer should be a function', trans.pos);
		});
		
		var resultFunction = EFunction(null, {
			args: inputArgs,
			ret: null,
			expr: macro {
				var changed = false;
				${EVars(newVars).at()}
				$b{checks}
				
				if(changed) __value = $trans($a{results});
				return __value;
			},
		}).at();
		
		return macro {
			var __value;
			${EVars(oldVars).at()}
			${ECheckType(resultFunction, resultFunctionType).at()}
		};
	}
}