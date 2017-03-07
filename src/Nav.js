import React from 'react'
import { Menu ,Icon ,Dropdown} from 'antd'
import { FormattedMessage } from 'react-intl'

export default class Nav_Mobile extends React.Component{

  constructor(props){
    super(props);
    this.state = {
      classCaidan: false,
    };
  }
  caidan=()=>{
    this.setState({classCaidan:!this.state.classCaidan});
  }
  render() {
    var classCaidan=this.state.classCaidan;
    if(!this.props.isMobile){
      return (
        <div>
          <div className="App-Logo">
            <img alt="img" src={require("../public/logo.png")} style={{width: '45px', margin: '10px'}}/>
            <span>MoeCube</span>           
          </div>
          <Menu
            theme="dark"
            mode="horizontal"
            defaultSelectedKeys={['1']}
            style={{ lineHeight: '64px' }}>

            <Menu.Item key="1">
              <FormattedMessage id={"Home"}/>            
            </Menu.Item>
            <Menu.Item key="2">
              <a href="https://ygobbs.com/">
                <FormattedMessage id={"BBS"}/>
              </a>
            </Menu.Item>
          </Menu>
        </div>
      );
    }else{
      return (
        <div>
          <div style={{position:'fixed',zIndex:10,width:'100%',background:'#404040'}}>
            <div className="App-Logo">
              <img alt="img" src={require("../public/logo.png")} style={{width: '45px', margin: '10px'}}/>
              <span>MoeCube</span>           
            </div>
            <div className="square" onClick={this.caidan}>
              <Icon type="down-circle-o" />
            </div>
          </div>
          <ul className={ classCaidan ? "caidan cshow" : "caidan chidden" }>
            <a href="#">
              <li>
                <FormattedMessage id={"Home"}/>  
              </li>          
            </a>
            <a href="https://ygobbs.com/">
              <li>
                <FormattedMessage id={"BBS"}/>
              </li>
            </a>
          </ul>
        </div>
      )
    }
  }
}