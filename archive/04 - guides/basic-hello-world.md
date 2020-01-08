Create an ES6 style model

```js
class LoginModel {
  constructor(modelId, router) {
    this._modelId = modelId;
    this._router = router;
    this.username = 'anonymous';
  }
  // observe events using decorators 
  @esp.observeEvent('setUsername')
  _onSetUsername(event) {
    this.username = event.username;
  }
  registerWithRouter() {
    // register the model with the router
    this._router.addModel(this._modelId, this);
    // instruct the router to hook up decorated event observation methods 
    this._router.observeEventsOn(this._modelId, this);      
  }
}
```

Create an app wide router.

```js
let router = new esp.Router();  
```


All models are identified by an ID so let's create one.

```js
let loginModelId = 'loginModelId';
```


Create an instance of your model.

```js
let loginModel = new LoginModel(loginModelId, router); 
// instruct it to register itself with the router
loginModel.registerWithRouter();
```

Observe the model for changes, typically done in a view.

```js
let subscription = router
  .getModelObservable(loginModelId)
  // the router has a built-in observable API with basic methods, filter(), do(), map(), take() 
  .do(model =>  { /* gets invoked on each update */ })
  .subscribe(model => {
      console.log(`Updating view. Username is: ${model.username}`);
      // ... update the view 
    }
  );
```


Publish an event to change the models state, typically done from a view.
The router will fan-out delivery of the event to observers in your model using an [event workflow](content/advanced-concepts/complete-event-workflow.md).
When event processing is finished the router will fan-out deliver of the model to observers.

```js
router.publishEvent(loginModelId, 'setUsername', {username:'ben'});
```

Stop observing the model
```js
subscription.dispose();      
```

Output

```
"Updating view. Username is: anonymous"
"Updating view. Username is: ben"
```
