import React from "react";

export class FairDiceGame extends React.Component {
    numberOfRolls: number = 10000;
    resultList: JSX.ElementClass[] = [];
  
    constructor(props: {} | Readonly<{}>) {
      super(props)
      
      Math.seedrandom(new Date().getMilliseconds());
  
      this.numberOfRolls = 10000;
      this.resultList = [];
      
      this.state = {
          items: [
            { name: "A", text: "A with numbers 2, 4 and 9", selected: true, value: 0, numbers: [2, 4, 9, 2, 4, 9] },
          { name: "B", text: "B with numbers 1, 6 and 8", selected: false, value: 1, numbers: [1, 6, 8, 1, 6, 8] },
          { name: "C", text: "C with numbers 3, 5 and 7", selected: false, value: 2, numbers: [3, 5, 7, 3, 5, 7] },
        ],
        rollResults: [],
        gameSummary: [],
        showNote: false,
        showNoteB: false,
        showNoteC: false,
        showNoteD: false,
        showRollResults: false,
        gamesPlayed: 0,
        userGamesWon: 0,
        cpuGamesWon: 0
      }
    }
    
    rollDie(die: { numbers: string | any[]; }) {
        return die.numbers[Math.floor(Math.random() * 100 % die.numbers.length)];
    }
    
    getComputerGameDie(userSelection: { value: any; }) {
      switch (userSelection.value) {
          case 0: {
            return this.state.items[2];
          }
          case 1: {
            return this.state.items[0];
          }
          case 2: {
            return this.state.items[1];
          }
      }
    }
    
    setSelection(e) {
        let newState = this.setState(prevState => {
          let newItemState = prevState.items.map(item => {
            item.selected = (item.value == e.target.value);
          return item;
        });
        
        return {items: newItemState}
      })
    }
    
    playGame() {
      let tempResults = [];
      let userWins = 0, cpuWins = 0, totalUserWins = this.state.userGamesWon, totalCPUWins = this.state.cpuGamesWon;
      
      let userDie = this.state.items.find(item => {return item.selected});
      let cpuDie = this.getComputerGameDie(userDie);
      
      for(var i = 0; i < this.numberOfRolls; i++) {
          let userRoll = this.rollDie(userDie);
          let cpuRoll = this.rollDie(cpuDie);
  
          if (userRoll > cpuRoll) {
            ++userWins;
            ++totalUserWins;
          } else {
            cpuWins++;
            ++totalCPUWins;
          }
  
          let resultString = `${userDie.name}: ${userRoll} ${cpuDie.name}: ${cpuRoll}`;
          let scoreTally = `Score: ${userWins} to ${cpuWins}`;
          tempResults.push((<li>{resultString} {scoreTally}</li>));
      }
      
      let gameSummary = this.buildGameSummary(userDie, userWins, totalUserWins, cpuDie, cpuWins, totalCPUWins);
          
      this.setState(prevState => {
          let totalGames = prevState.gamesPlayed+1;
            return {
                  rollResults: tempResults,
              gameSummary: gameSummary,
              gamesPlayed: totalGames, 
              showNote: totalGames >= 5 && totalGames < 10,
              showNoteB: totalGames >= 10 && totalGames < 15,
              showNoteC: totalGames >= 15 && totalGames < 20,
              showNoteD: totalGames >= 20,
              userWins: totalUserWins,
              cpuWins: totalCPUWins,
          };
      });
    }
    
    buildGameSummary(userDie, userWins, totalUserWins, cpuDie, cpuWins, totalCPUWins) {
    let tempSummary = [];
        tempSummary.push(<h2>Games Won</h2>);
      tempSummary.push(<li style={{marginLeft: '10px'}}>You: {totalUserWins} AI: {totalCPUWins}</li>);
      tempSummary.push((<li>You chose {userDie.name} and I chose {cpuDie.name}</li>));
          tempSummary.push((<li>Score: {userDie.name} = {userWins} {cpuDie.name} = {cpuWins}</li>));
      
      if (userWins > cpuWins) {
              
            tempSummary.push((<li>You're just lucky...this time. Want to wager on the next one?</li>));
      } else {
            tempSummary.push((<li>Too bad. I win. Better luck next time.</li>));
      }
      
      return tempSummary;
    }
    
    showRollResultsChanged(e) {
        this.setState(prevState => {
          return {
            showRollResults: e.target.checked
        }
      })
    }
    
    gameResults() {
    if (this.state.rollResults.length == 0) return <div />;
    
        return 
          <div>
            <h1 style={{marginTop: '20px'}}>Summary</h1>
            <p>Games Played: {this.state.gamesPlayed}</p>}
            <p>Games Won: You - {this.state.userGamesWon} Computer: {this.state.cpuGamesWon}</p>}
            {this.teaseNote()}
            <div><input type="checkbox" id="rollResults"onChange={this.showRollResultsChanged.bind(this)} checked={this.state.showRollResults} /><label>Show roll results</label></div>
            {this.state.showRollResults && <div style={{marginTop: '20px'}}><h1>Roll Results</h1><ol>{this.state.rollResults}</ol></div>}
        </div>
    }
    
    teaseNote() {
        return 
            <li>
            {this.state.showNote == true && <p style={{color: 'tomato'}}>Note: You keep losing. Why? Am I cheating?</p>}
            {this.state.showNoteB == true && <p style={{color: 'tomato'}}>Note: You're a glutton for punishment aren't you? How do I keep winning?</p>}
            {this.state.showNoteC == true && <p style={{color: 'tomato'}}>Note: In case you're wondering, I'm not cheating.</p>}
            {this.state.showNoteD == true && <p style={{color: 'tomato'}}>Note: Still curious how? Do a search for 'intransitive dice'. You're welcome.</p>}
          </li>
    }
    render() {
      return (
        <div>
        <h1>Mark Schmidt's Fair Dice Game</h1>
          <p>I have 3 dice. You can choose whatever dice you want to roll. There are 6 sides on each die with 3 numbers. For instance, die A has the number 2 on the top and bottom sides, the number 4 on the front and back and the number 9 on the left and right sides. Die B has numbers 1, 6 & 8 and die C has 3, 5, & 7. You select a die to roll, I will choose a die from the remaining 2 dice and we will roll {this.numberOfRolls} times to see who wins. Select a die and hit Go to play!</p>
          <ol>
          {this.state.items.map(item => (
            <li key={item.id}>
              <label>
                <input onChange={this.setSelection.bind(this)} type="radio" name={"die"} value={item.value} checked={item.selected} /> 
                <span>{item.text}</span>
              </label>
            </li>
          ))}
          </ol>
          <input type="button" onClick={this.playGame.bind(this)} value="Go"/>
          {this.gameResults()}
        </div>
      )
    }
  }
  
  ReactDOM.render(<FairDiceGame />, document.querySelector("#app"))
  