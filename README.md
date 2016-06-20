# transform

Macro-based lazy object transformation.

In a unidirectional data flow model, like Flux or Redux, data are stored in a single root object called "state".
View components then extract the data from such state object and display them.
In the process, the view components often need to transform the raw data into some displayable form.

When the state is updated, a single event is dispatched to which components can subscribe,
and they will update the views by getting the updated state and transform it again.
But since the event does not contain information about what specifically has been changed in the state object,
it would be wasteful if a component do the transformation again even the specific part of
the state the component is interested in has not been changed at all.

So in order to avoid unnecessary computations, we can add some logic to check whether the
underlying data has been changed before actually doing the transformation.

This library is inspired by Reselect and used macro to generate the transformation functions.

## Example

```haxe
inline function items(state) return state.items;
var subtotalCount = 0;
var subtotal = Transformer.create(items, function(items) {
	subtotalCount ++;
	return items.fold(function(item, sum) return sum + item.value, 0);
});


var state = {
	items: [
		{name: 'apple', value: 1.2},
		{name: 'orange', value: 0.95},
	]
}

trace(subtotal(state)); // 2.15
trace(subtotalCount); // 1, the fold function has been run
trace(subtotal(state)); // 2.15
trace(subtotalCount); // 1, the fold function has not been run again

// now we update our items array
state.items = state.items.concat([{name: 'pear', value: 1.0}]);
trace(subtotal(state)); // 3.15
trace(subtotalCount); // 2, the fold function has been run again
trace(subtotal(state)); // 3.15
trace(subtotalCount); // 2, the fold function has not been run again
```

In the above example, we can see that the `item.fold` will not be called again,
unless there is a change in `state.items`;
