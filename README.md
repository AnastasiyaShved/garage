![image](https://github.com/AnastasiyaShved/garage/assets/141756297/4ac4225d-0295-4cd7-8d29-81a400f46b88)
 
GARAGE will save you from having to keep your cars' service dates in your head, remind you about insurance, and keep your cars' service history.

Features
=====================
- [x] User authorisation
- [x] Password recovery 
- [x] Car information storage
- [x] Service scheduling
- [x] Reminder receipt
- [x] Service history storage
- [x] Data deletion and modification
- [x] Deadline visualisation
---
Usage Guide
=====================
<img width="907" alt="Снимок экрана 2024-02-07 в 17 30 51" src="https://github.com/AnastasiyaShved/garage/assets/141756297/97e89936-8ed8-4cc7-8f7c-ad66a690e33e">

Installation 
-----------------------------------
Download the source code and compile it yourself using Xcode. If you want to run it on your device, you will also need an Apple developer account.

Registration
-----------------------------------
Launch the application and register. If you need to recover your password, please click the "Forgot password" link.

Settings
-----------------------------------
To make full use of the app, in the device settings, turn on notifications.

Adding cars 
-----------------------------------
Create cars using the "Add" button. Use the scroll left to view your car fleet. The car becomes active when you click on a cell.
It is possible to change information about a car using the button in the upper right corner.
To create a maintenance notification, use the "Add" button after selecting a specific car.

Notifications
-----------------------------------
While creating a maintenance service, you need to specify the due date or mileage at which you want to notify about the service.
The application will request to update the car mileage at each login (necessary for correct operation of the notification service, if the scheduled maintenance depends on the actual car mileage).

History
-----------------------------------
Mark a scheduled service as completed to move it to History. The page stores all performed services for each car.

Instruments
=====================
- Firebase: Authentication, Realtime Database
- UIKit
- SwiftUI







