import React from 'react'
import { Menu, Icon } from 'antd'
import { FormattedMessage } from 'react-intl'
import querystring from 'querystring';
import crypto from 'crypto';
export default class Nav_Mobile extends React.Component {

  constructor(props) {
    super(props);

    var isLogin = false;
    var userName = "";
    var user;

    var token = querystring.parse(location.search.slice(1)).sso;
    if (token) {
      localStorage.setItem('token', token);
      user = querystring.parse(new Buffer(token, 'base64').toString());
      isLogin = true;
      userName = user.username;
    } else {
      token = localStorage.getItem('token');
      if (token) {
        user = querystring.parse(new Buffer(token, 'base64').toString());
        isLogin = true;
        userName = user.username;
      }
    }

    this.state = {
      classMenu: false,
      isLogin: isLogin,
      userName: userName
    };

  }

  login() {
    var payload = new Buffer(querystring.stringify({
      return_sso_url: location.href
    })).toString('base64');

    var request = querystring.stringify({
      'sso': payload,
      'sig': crypto.createHmac('sha256', 'zsZv6LXHDwwtUAGa').update(payload).digest('hex')
    });
    location.href = "https://ygobbs.com/session/sso_provider?" + request;
  }

  logout() {
    localStorage.removeItem('token');

    // var redirectUrl = "http://localhost:3001/#";
    var redirectUrl = "https://mycard.moe/";
    this.setState({ isLogin: false });
    var request = querystring.stringify({
      'redirect': redirectUrl
    });
    location.href = "https://ygobbs.com/logout?" + request;
  }

  menu = () => {
    this.setState({ classMenu: !this.state.classMenu });
  }
  render() {
    const {  isLogin } = this.state
    var classMenu = this.state.classMenu;
    var userName = this.state.userName;
    if (!this.props.isMobile) {
      return (
        <div>
          <div className="App-Logo">
            <img alt="img" src={require("../public/logo.png")} style={{ width: '140px', margin: '10px' }} />
          </div>
          <Menu
            theme="dark"
            mode="horizontal"
            defaultSelectedKeys={['1']}
            style={{ lineHeight: '64px' }}>

            <Menu.Item key="1">
              <FormattedMessage id={"Home"} />
            </Menu.Item>
            <Menu.Item key="2">
              <a href="https://ygobbs.com/">
                <FormattedMessage id={"BBS"} />
              </a>
            </Menu.Item>
            <Menu.Item key="9">
              <a href="https://mycard.moe/ygopro/arena/index.html">
                <FormattedMessage id={"DataBase"} />
              </a>
            </Menu.Item>
            <Menu.Item key="3">
              <a href="https://accounts.moecube.com/">
                用户中心
              </a>
            </Menu.Item>

            {isLogin ?
              (<Menu.Item key="5" style={{ float: 'right' }}>
                <a onClick={() => this.logout()} >
                  退出
                  </a>
              </Menu.Item>) : ("")}

            {!isLogin ?
              (<Menu.Item key="4" style={{ float: 'right' }}>
                <a onClick={() => this.login()} >
                  注册 | 登录
                  </a>
              </Menu.Item>) :
              (<Menu.Item key="4" style={{ float: 'right' }}>
                <a href="#" >
                  {userName}
                  </a>
              </Menu.Item>)}

          </Menu>
        </div>
      );
    } else {
      return (
        <div>
          <div style={{ position: 'fixed', zIndex: 10, width: '100%', background: '#404040' }}>
            <div className="App-Logo">
              <img alt="img" src={require("../public/logo.png")} style={{ width: '140px', margin: '10px' }} />
            </div>
            <div className="square" onClick={this.menu}>
              <Icon type="down-circle-o" />
            </div>
          </div>
          <ul className={classMenu ? "menu cshow" : "menu chidden"}>
            <a href="#">
              <li>
                <FormattedMessage id={"Home"} />
              </li>
            </a>
            <a href="https://ygobbs.com/">
              <li>
                <FormattedMessage id={"BBS"} />
              </li>
            </a>
          </ul>
        </div>
      )
    }
  }
}