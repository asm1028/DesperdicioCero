// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyDE38mIJRYg1xdXHyxdsphnVyXTxlkO6DM",
  authDomain: "desperdiciocero-f3a23.firebaseapp.com",
  projectId: "desperdiciocero-f3a23",
  storageBucket: "desperdiciocero-f3a23.appspot.com",
  messagingSenderId: "185732800857",
  appId: "1:185732800857:web:e263841f42d166fee46c48",
  measurementId: "G-JB8C31JJB6"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);