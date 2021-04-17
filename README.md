# applysis-ios-sdk

## A description of this package.
Applysis iOS SDK gives opportunity to submit feedback automatically from iOS, OSX, WatchOS or TVOS apps directly to [Applysis platform](https://app.applysis.io/).

## Supported Versions
* iOS from 13.0
* OSX from 10.15
* TVOS from 13.0
* WatchOS from 6.0

## Usage
Before you start using the Package, you should add new API source on Applysis platform and generate the secret key. All details are explained [here](http://docs.applysis.io/)

### Initialising
Import `Applysis` in AppDelegate.swift and add initalisiation in `didFinishLaunchingWithOptions`.

`Applysis.initalise(with: "your-secret-key")`

##### Debug Mode
If you wish to enable the debug mode you can call:
`Applysis.shared.enableDebugMode()`
It will log all network parameters, headers, body and response. It will help you debug bad requests or any other issues.

### Submission
Applysis SDK provides the `Feedback` structure which contains:
-   **text**: mandatory, e.g review text, email body etc.
-   **title**: optional, e.g email subject, question, review title etc.
-   **date**: optional.
-   **rating**: optional, e.g review rating, we expect it to be minimum 1, maximum 5
-   **author**: optional, e.g user name, email address.
-   **region**: optional, it can hold any region value you desire e.g country, city, county.
-   **version**: optional, e.g 1.5, 1.6.1 etc.

SDK uses Combine to notify callee about the submission success or failure. So, initialise `Feedback` structure with the data you want to submit and then submit it with the SDK.

```
let feedback = Feedback(
                    text: "Sending messages fails, please fix ASAP!", 
                    title: "Bug on message sending", 
                    date: Date(), 
                    rating: nil, author: nil, region: nil, version: nil
                    )
                    
Applysis.shared.submitFeedback(feedback)
            .sink(receiveCompletion: { [weak self] resp in
                switch resp {
                    case .finished:  break // finished
                    case .failure: break // error
                }
            }, receiveValue: { [weak self] _ in
                // success
            })
            .store(in: &cancellables)
```

##### Submission by batches
Submission can be done batch by batch. You can use `Applysis.shared.submitFeedbacks(_ feedbacks: [Feedback])` to submit maximum 50 feedbacks at a time.

If feedback(s) was successfully submitted, it should be visible on [Applysis platform](https://docs.applysis.io/API/a-creating-api-source/) in maximum next 10-15 minutes.

## Limitations
* You can not submit more than 50 feedbacks at a single batch.
* With the current plans, you can submit maximum 2000 feedbacks in a month.
* `text` field can not be `nil` nor empty.
 
For any issues or technical difficulties, please reach out **contact@applysis.io**
