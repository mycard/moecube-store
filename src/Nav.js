import React from 'react'
import { Menu, Icon } from 'antd'
import { FormattedMessage } from 'react-q'

export default class Nav_Mobile extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      classMenu: false,
    };
  }
  menu = () => {
    this.setState({ classMenu: !this.state.classMenu });
  }
  render() {
    var classMenu = this.state.classMenu;
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
            <Menu.Item key="3">
              <a href="https://mycard.moe/ygopro/arena/index.html">
                <FormattedMessage id={"DataBase"} />
              </a>
            </Menu.Item>
            <Menu.Item key="3">
              <a href="https://accounts.moecube.com/">
                用户中心
              </a>
            </Menu.Item>
            <Menu.Item key="#">
              <a href="#">
                客服中心
              </a>
            </Menu.Item>
            <Menu.Item key="5">
              <a href="#">
                最新资讯
              </a>
            </Menu.Item>
            <Menu.Item key="6">
              <a href="#">
                创意分享
              </a>
            </Menu.Item>
            <Menu.Item key="7">
              <a href="#">
                最新科技
              </a>
            </Menu.Item>
            <Menu.Item key="8">
              <a href="#">
                学习天地
              </a>
            </Menu.Item>
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