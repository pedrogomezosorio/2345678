
# MVVM pattern

## Flowchart

```mermaid
flowchart LR

%% LAYERS
A[User Interface Widgets: MyApp, FriendsScreen,<br>FriendRow, FriendDialog, InfoBar] 
B[FriendViewModel]
C[ Repositories<br>FriendRepository]
D[ Services<br>SplitWithMeService,<br>SplitWithMeAPIService,]
E[ DTOs<br>Friend]

%% FLOW
B -- fetches / modifies data --> MODEL
MODEL -- returns data / errors --> B
A -- observes & sends user actions --> B
B -- updates View via notifyListeners() --> A

%% DECORATION
subgraph VIEW
A
end

subgraph VIEWMODEL
B
end

subgraph MODEL
C
D
E
end
```


## Class Diagram: View
```mermaid

classDiagram

%%=========================
%% UI Layer
%%=========================
class MyApp:::group1{
  +build(context: BuildContext) Widget
}

class FriendsScreen:::group2 {
  +title: String
  +viewModel: FriendViewModel
  +createState() State<FriendsScreen>
}

class _FriendsScreenState:::group2 {
  +build(context: BuildContext) Widget
}

class FriendRow:::group2 {
  +friend: Friend
  +onRemove: Command1
  +build(context: BuildContext) Widget
}

class InfoBar:::group2 {
  +message: String
  +onPressed: Function
  +isError: bool
  +build(context: BuildContext) Widget
}

class FriendDialog:::group3 {
  +viewModel: FriendViewModel
  +createState() State<FriendDialog>
}

class _FriendDialogState:::group3 {
  -_formKey: GlobalKey<FormState>
  -nameController: TextEditingController
  +build(context: BuildContext) Widget
}

class FriendDetailsScreen:::group4 {
  +friend: Friend
  +build(context: BuildContext) Widget
}

%%=========================
%% ViewModel Layer
%%=========================
class FriendViewModel {
}



class Friend:::group5 {
  +id: int?
  +name: String
  +creditBalance: double?
  +debitBalance: double?
  +starred: bool
  +Friend.fromJson(Map)
  +toString() String
}

classDef group1 fill:#e4fff6;
classDef group2 fill:#e3ffd7;
classDef group3 fill:#ddc2ff;
classDef group4 fill:#cdd3ff;
classDef group5 fill:#ffdcf1;



%%=========================
%% Relationships
%%=========================
MyApp --> FriendsScreen : creates
_FriendsScreenState ..> FriendViewModel : observes
FriendsScreen --> FriendViewModel : uses
_FriendsScreenState --> FriendsScreen : state of
_FriendsScreenState --> InfoBar : displays messages on
_FriendsScreenState --> FriendRow : creates
FriendViewModel --> Friend : manages
FriendDialog --> FriendViewModel : interacts with
_FriendDialogState --> FriendDialog: state of
FriendRow --> Friend : displays
FriendDetailsScreen --> Friend : displays
_FriendsScreenState ..> FriendDetailsScreen : navigates to
_FriendsScreenState ..> FriendDialog : opens
```

## Class diagram: ViewModels, Respositories and Services

```mermaid
classDiagram


%%=========================
%% ViewModel Layer
%%=========================
class FriendViewModel:::group3 {
  -_friendRepository: FriendRepository
  +friends: List<Friend>
  +errorMessage: String?
  +load: Command0
  +addFriend: Command1<void, String>
  +removeFriend: Command1<void, int>
  +_load() Future<Result<void>>
  +_addFriend(String name) Future
  +_removeFriend(int id) Future
}

%%=========================
%% Data Layer
%%=========================
class FriendRepository:::group1 {
  -_service: SplitWithMeService
  +fetchFriends() Future
  +addFriend(friend: Friend) Future
  +removeFriend(id: int) Future
}

class SplitWithMeService:::group2 {
  <<abstract>>
  +fetchFriends() Future
  +addFriend(friend: Friend) Future
  +removeFriend(id: int) Future
}

class SplitWithMeAPIService:::group2 {
  +serverURL: String
  +serverPort: String
  +fetchFriends() Future
  +addFriend(friend: Friend) Future
  +removeFriend(id: int) Future
}

class Friend:::group5 {
  +id: int?
  +name: String
  +creditBalance: double?
  +debitBalance: double?
  +starred: bool
  +Friend.fromJson(Map)
  +toString() String
}

class ServerException:::group5 {
  +errorMessage: String
}

%%=========================
%% External/Utility Classes
%%=========================
class Command0 {
  <<generic>>
  +execute()
  +running: bool
  +error: bool
  +clearResult()
}

class Command1 {
  <<generic>>
  +execute(arg)
  +running: bool
  +error: bool
  +clearResult()
}

class Result {
  <<sealed>>
  +ok(value)
  +error(error)
}


classDef group1 fill:#e4fff6;
classDef group2 fill:#e3ffd7;
classDef group3 fill:#ddc2ff;
classDef group4 fill:#cdd3ff;
classDef group5 fill:#ffdcf1;



SplitWithMeAPIService --|> SplitWithMeService
SplitWithMeService ..> Friend :uses 
SplitWithMeService ..> ServerException : throws
FriendRepository --> SplitWithMeService
FriendViewModel --> FriendRepository
note for FriendRepository "Service is defined by dependency<br>injection in the main function"
FriendViewModel --> Command0 : load command
FriendViewModel --> Command1 : addFriend 
FriendViewModel --> Command1 : removeFriend 
FriendRepository ..> Result : uses
FriendViewModel ..> Result : uses
```

## Sequence diagram: load list of friends

```mermaid
sequenceDiagram
    autonumber
    participant User
    participant FriendsScreen
    participant FriendViewModel
    participant Command0
    participant FriendRepository
    participant SplitWithMeService
    participant FriendList as List<Friend>

    Note over FriendsScreen: App starts or user opens FriendsScreen

    User ->> FriendsScreen: View appears
    FriendsScreen ->> FriendViewModel: load.execute()

    Note over Command0: Command0 sets running = true
    Command0 ->> FriendsScreen: notifies listeners (running = true)
    FriendsScreen ->> FriendsScreen: show CircularProgressIndicator()

    Note over FriendViewModel: _load() is invoked
    FriendViewModel ->> FriendRepository: fetchFriends()
    FriendRepository ->> SplitWithMeService: fetchFriends() API call

    SplitWithMeService -->> FriendRepository: List<Friend> or Exception

    alt success (Ok)
        FriendRepository -->> FriendViewModel: Result.ok(List<Friend>)
        FriendViewModel ->> FriendList: update friends list
    else failure (Error)
        FriendRepository -->> FriendViewModel: Result.error(Exception)
        FriendViewModel ->> FriendViewModel: set errorMessage
    end

    Note over FriendViewModel: Notifies listeners after update
    FriendViewModel ->> Command0: set running = false
    Command0 ->> FriendsScreen: notifies listeners (running = false)
    FriendsScreen ->> FriendsScreen: hide CircularProgressIndicator()

    alt success
        FriendsScreen ->> FriendsScreen: rebuild UI with friend list
    else error
        FriendsScreen ->> FriendsScreen: display InfoBar with error
    end

    Note over FriendsScreen: UI shows final state (friends or error)
```

## Sequence diagram: add a new friend
```mermaid
sequenceDiagram
    autonumber
    participant User
    participant FriendDialog
    participant FriendViewModel
    participant Command1
    participant FriendRepository
    participant SplitWithMeService
    participant FriendsScreen

    Note over FriendDialog: User enters friend's name and presses "Add"
    User ->> FriendDialog: Tap "Add" button
    FriendDialog ->> FriendViewModel: addFriend.execute(name)

    Note over Command1: Command1 sets running = true
    Command1 ->> FriendsScreen: notifies listeners (running = true)
    FriendsScreen ->> FriendsScreen: show CircularProgressIndicator()

    Note over FriendViewModel: _addFriend(name) is invoked
    FriendViewModel ->> FriendRepository: addFriend(Friend(name))

    FriendRepository ->> SplitWithMeService: addFriend(friend)
    SplitWithMeService -->> FriendRepository: returns new Friend or Exception

    alt success (Ok)
        FriendRepository -->> FriendViewModel: Result.ok(Friend)
        FriendViewModel ->> FriendViewModel: add Friend to friends list
        FriendViewModel ->> FriendsScreen: notifyListeners()
        FriendsScreen ->> FriendsScreen: rebuild UI with updated list
    else failure (Error)
        FriendRepository -->> FriendViewModel: Result.error(Exception)
        FriendViewModel ->> FriendViewModel: set errorMessage
        FriendViewModel ->> FriendsScreen: notifyListeners()
        FriendsScreen ->> FriendsScreen: display InfoBar with error
    end

    Note over FriendViewModel: Operation finished
    FriendViewModel ->> Command1: set running = false
    Command1 ->> FriendsScreen: notifies listeners (running = false)
    FriendsScreen ->> FriendsScreen: hide CircularProgressIndicator()

    Note over FriendsScreen: UI reflects success (new friend added) or error message
```

## Sequence diagram: remove a friend

```mermaid
sequenceDiagram
    autonumber
    participant User
    participant FriendsScreen
    participant FriendRow
    participant FriendViewModel
    participant Command1
    participant FriendRepository
    participant SplitWithMeService

    Note over FriendsScreen: Friends list is displayed
    User ->> FriendRow: Tap delete icon 🗑️
    FriendRow ->> Command1: execute(friend.id)
    Command1 ->> FriendViewModel: _removeFriend(friend.id)

    Note over Command1: Command1 sets running = true
    Command1 ->> FriendsScreen: notifies listeners (running = true)
    FriendsScreen ->> FriendsScreen: show CircularProgressIndicator()

    Note over FriendViewModel: Calls repository to remove the friend
    FriendViewModel ->> FriendRepository: removeFriend(id)
    FriendRepository ->> SplitWithMeService: removeFriend(id) HTTP DELETE
    SplitWithMeService -->> FriendRepository: Response (success or error)

    alt success (Ok)
        FriendRepository -->> FriendViewModel: Result.ok(void)
        FriendViewModel ->> FriendViewModel: remove friend from list
        FriendViewModel ->> FriendsScreen: notifyListeners()
        FriendsScreen ->> FriendsScreen: rebuild UI (updated list)
    else failure (Error)
        FriendRepository -->> FriendViewModel: Result.error(Exception)
        FriendViewModel ->> FriendViewModel: set errorMessage = "Cannot remove friend"
        FriendViewModel ->> FriendsScreen: notifyListeners()
        FriendsScreen ->> FriendsScreen: display InfoBar with error message
    end

    Note over FriendViewModel: Operation complete
    FriendViewModel ->> Command1: set running = false
    Command1 ->> FriendsScreen: notifies listeners (running = false)
    FriendsScreen ->> FriendsScreen: hide CircularProgressIndicator()

    Note over FriendsScreen: UI reflects updated friend list or error

```