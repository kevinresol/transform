package transform;

class Transformer<S, T> {	
	public static inline function eq<T>(a:T, b:T)
		return a == b;
		
	public static macro function create(args, trans, ?eq) {
		return TransformerMacro.create(args, trans, eq);
	}
}