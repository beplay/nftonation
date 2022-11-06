import React, {useState} from "react";
import logo from './images/NFTonation.png';
import './App.css';
import {Voter} from "./components/Voter";
import {SectionDivider} from "./components/SectionDivider";
import {StartPage} from "./components/StartPage";


function App() : JSX.Element {



    return (
        <div className="App">
            <header className="App-header">
                <img src={logo} className="App-logo" alt="logo" />
            </header>
            <main className="App-body">
            {/*<Voter />*/}
            <SectionDivider />
            <StartPage />
            <SectionDivider />


            </main>
        </div>

    );
}

export default App;
