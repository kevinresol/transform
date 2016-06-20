package transform;

import haxe.macro.Expr;
import haxe.macro.Context;
using tink.MacroApi;

class TransformerMacro {
	public static function create(args:Expr, trans:Expr, eq:Expr) {
		var oldVars = [];
		var newVars = [];
		var results = [];
		var checks = [];
		
		eq = eq.ifNull(macro Transformer.eq);
		
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
			newVars.push({name: newVarName, expr: macro $expr(s), type: null});
			checks.push(macro if(!$eq($oldVar, $newVar)) {
				changed = true;
				$oldVar = $newVar;
			});
		}
		
		switch args.expr {
			case EArrayDecl(values):
				for(i in 0...values.length) handle(i, values[i]);
			default:
				handle(0, args);
		}
		
		return macro {
			var __value;
			${EVars(oldVars).at()}
			function(s) {
				var changed = false;
				${EVars(newVars).at()}
				$b{checks}
				
				if(changed) __value = $trans($a{results});
				return __value;
			}
		};
	}
}