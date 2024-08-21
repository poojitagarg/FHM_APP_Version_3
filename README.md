# Fetal Health Monitoring App
This is the project under the [ Uncommon Sense Labs](https://www.uncommonsenselabs.com) directed by Dr. Alexander Adams at GaTech. The project code is developed by Poojita Garg.

## Objective of the App
The goal of this research is to build an easy-to-use system for ubiquitous at-home monitoring of fetal health by pregnant women. This study will recruit 20 currently pregnant women. We will collect audio data from the mobile phone (i.e. reflections from the ultrasound signal emitted by the mobile device's speaker). All the participant's data will be de-identified and coded for analysis. 

## Backend of the App
The App is developed in Xcode 15.1 and Swift 5.9.2 to be used by iphone users only at the time. The proposed methodology of the study includes the app to be used by the medical professional on their personal phone to non-invasively collect audio data by placing the mobile phone (speaker side of the belly with this app opened) on the belly of the pregnant lady. 

## Use of the App
The app will be opened and placed on the belly of the pregnant women with the speaker side touching the belly. There are three screens of the app. 

1. The first screen presents an text-entry page for the doctor to enter the custom-assigned patient ID at the time of consent process, the ground truth collected by the medical professional before using the device by using the gold standard device and the gestation period of the pregnancy.
<img src="https://github.com/user-attachments/assets/a4f255db-9190-4076-ab4f-ccb8aa9c2484" width=50% height=50%>

2. The second screen is where the data is collected and a waveform animation is shown for feedback. On hitting the start button, the ultrasound audio transmission as well as audio recording starts together to collect the reflections from the ultrasound signal emitted by the mobile device's speaker. There is a timer that shows how much total time is remaining till the audio recording and transmitting ends at the same time. For now, the timer shows 5 seconds but it can vary upto 1-2 minutes as per requiremnt for data analysis. There is also a stop button to stop the recording anytime while the session is going on. 
<img src="https://github.com/user-attachments/assets/d4e57f16-bb88-4e18-a0f6-ed115cc6ff82" width=50% height=50%>

3. The last page records feedback from the doctor regarding the data collection session and re-directs to either the first page if the data collection was satisfactory or the second if the data collection was not satisfactory and the medical professional would like re-record the data.
<img src="https://github.com/user-attachments/assets/21499944-e20c-44e6-86fc-6de2ae4b32f8" width=50% height=50%>


## Features of the App
### The App Outputs:
1. The app shows a waveform animation of the audio being collected.
2. The app shows a timer running while the audio is being collected.
3. The phone's speaker transmits a 16 bit sine wave at 20000Hz that falls under ultrasound category of sound for the fetal heart rate analysis.

**Note:** The app **is not** intended to show the predicted values of the fetal heart rate to the user to avoid false positives.

### The App Inputs:
1. Patient ID (text entry from the doctor).
2. Ground Truth (text entry from the doctor).
3. Gestation period (text entry from the doctor).
4. Microphone audio is collected through the app.
5. feedback from the medical professional regarding whether the data recording process was satisfactory or not(text entry from the doctor).

## DataBase
We use Firebase with a secured Uncommon sense labs' gmail account to store all the collected data. The data is also stored locally on the phone of the doctor (the phone used to collect the data).

## Data Processing
The app at the time is solely used for data collection purposes and the data processing is done asynchronously bythe researchers using a seperate python file after the data collection is over.

