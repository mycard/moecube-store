import React from 'react'
import { Menu ,Icon ,Dropdown} from 'antd'
import { FormattedMessage } from 'react-intl'
// const SubMenu = Menu.SubMenu;
// const MenuItemGroup = Menu.ItemGroup;

export default class Nav_Mobile extends React.Component{

  handleClick = (e) => {
    console.log('click ', e);
  }
  render() {
    const menu=(
          <Menu style={{width:'100%'}}>
            <Menu.Item key="0">
              <a href="#">1st menu item</a>
            </Menu.Item>
            <Menu.Item key="1">
              <a href="#">2nd menu item</a>
            </Menu.Item>
            <Menu.Divider />
            <Menu.Item key="3">3d menu item</Menu.Item>
          </Menu>
    )
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
        <div >
          <div className="App-Logo">
            <img alt="img" src={require("../public/logo.png")} style={{width: '45px', margin: '10px'}}/>
            <span>MoeCube</span>           
          </div>

          <Dropdown overlay={menu} trigger={['click']}>
            <a className="ant-dropdown-link" href="#">
              Click me <Icon type="down" />
            </a>
          </Dropdown>

          
        </div>
      )
    }
  }
}