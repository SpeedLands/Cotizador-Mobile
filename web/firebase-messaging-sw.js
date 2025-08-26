importScripts("https://www.gstatic.com/firebasejs/12.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/12.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyDHekm0zWiZ7gBoq-3TX1yGw3tbOeUFGsU",
    authDomain: "mapolato-27709.firebaseapp.com",
    databaseURL: "...",
    projectId: "mapolato-27709",
    storageBucket: "mapolato-27709.firebasestorage.app",
    messagingSenderId: "472013534602",
    appId: "1:472013534602:web:97f81f32ebd5968fc84473",
    measurementId: "G-J7FZNELB3G"
});

const messaging = firebase.messaging();