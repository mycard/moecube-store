import React, { Component } from 'react'
import enquire from 'enquire.js'
import * as yaml from 'js-yaml'

import './App.css'
import config from './config'
import i18Data from '../i18data.json'

import { FormattedMessage } from 'react-intl'
import { Layout, Row, Col, Button, Card, Timeline, Dropdown, Menu, Icon } from 'antd'
import { Link } from 'react-router'

const { Content, Footer, Header } = Layout

import Nav from './Nav'



export default class App extends Component {
  constructor(props) {
    super(props)

    this.state = {
      isMobile: false,
      stats: { signups: null, online: null },
      latest: { win32: {}, drawin: {} },
      platform: navigator.platform.match(/Mac/i) ? 'drawin' : 'win32'
    }
  }

  async componentDidMount() {
    enquire.register('only screen and (max-width: 767px)', {
      match: () => {
        this.setState({ isMobile: true })
      },
      unmatch: () => {
        this.setState({ isMobile: false })
      }
    })

    const initState = {
      stats: {
        signups: await this.get_stats_signups(),
        online: await this.get_stats_online()
      }
    }
    const initLatest = {
      latest: {
        win32: await this.get_latest_win32(),
        drawin: await this.get_latest_drawin()
      }
    }

    this.setState(initState)
    this.setState(initLatest)
  }

  async get_latest_win32() {
    let rawData = await fetch(config.win32_url).then(res => res.text())
    let data = yaml.safeLoad(rawData)

    data.url = 'https://r.my-card.in/downloads/' + data.path
    return data
  }

  async get_stats_signups() {
    let params = new URLSearchParams();
    params.set('api_key', config.ygobbs.api_key);
    params.set('api_username', config.ygobbs.api_username);
    let data = await fetch(`${config.ygobbs.dashboard}?${params.toString()}`).then(res => res.json())

    return data.global_reports.find((item) => item.type === 'signups').total
  }

  async get_stats_online() {
    let rawText = await fetch('https://api.mycard.moe/stats/online').then(res => res.text())
    let document = new DOMParser().parseFromString(rawText, 'text/xml')
    let node = document.querySelector('#content > table > tbody > tr:nth-child(2) > td:nth-child(2)') || {}
    // eslint-disable-next-line
    return parseInt(node.textContent)
  }

  async get_latest_drawin() {
    let data = await fetch(config.drawin_url).then(res => res.json())
    data.url = data.url.replace('-mac.zip', '.dmg').replace('https://wudizhanche.mycard.moe/downloads/', 'https://r.my-card.in/downloads/')

    return data
  }

  changeLanguage(language) {
    localStorage.setItem('language', language);
    history.go(0);
  }

  handleClick = (e) => {
    console.log('click ', e);
  }

  render() {
    const { latest, isMobile, stats } = this.state
    const language = localStorage.getItem('language') || this.props.language
    const realData = i18Data[language] ? i18Data[language] : i18Data[this.props.language] ? i18Data[this.props.language] : i18Data['zh-CN']

    const menu = (
      <Menu style={{ transform: 'translateX(-16px)' }}>
        <Menu.Item key="0">
          <a onClick={() => this.changeLanguage('en-US')} className='changelanguage'>
            <img alt="img" src={require('../public/flag-us.png')} />
            &nbsp;English</a>
        </Menu.Item>
        <Menu.Item key="1">
          <a onClick={() => this.changeLanguage('zh-CN')} className='changelanguage'>
            <img alt="img" src={require('../public/flag-cn.png')} />
            &nbsp;中文</a>
        </Menu.Item>
      </Menu>
    );

    return (
      <Layout>

        {!isMobile ?
          (<Header style={{ width: '100%' }}>
            <Nav isMobile={isMobile} />
          </Header>) :
          (<Header style={{ width: '100%', padding: 0 }}>
            <Nav isMobile={isMobile} />
          </Header>
          )}
        <Content className="App-Content1">
          (<Row type="flex" justify="space-around" align="middle" >
            <Col span={24} style={{ display: "flex", flexDirection: 'column', alignItems: 'center' }}>

              <img alt="img" src={require('../public/cubbit-full-512.png')} className="App-Poster" />

              <div className="App-Poster-Content">
                <div className="title">
                  <FormattedMessage id="MoeCubeDoujinGamePlatform" />
                  <span className="sub">
                    Beta
                  </span>
                </div>
                {latest[this.state.platform].url ? (
                  <div style={{ textAlign: 'center' }}>
                    <div className="font-C-Gray">
                      <FormattedMessage id="SupportBoth" />
                      <DownLoadLink text='Windows' data={latest.win32} />
                      <FormattedMessage id="And" />
                      <DownLoadLink text='Mac' data={latest.drawin} />
                      <FormattedMessage id="OperationSystem" />
                    </div>
                    <a href={latest[this.state.platform].url}>
                      <Button type="primary" icon="download" size='large'>
                        <FormattedMessage id={"Download"} />
                      </Button>
                    </a>
                  </div>
                ) : (
                    <div className="loading">Loading...</div>
                  )}
              </div>
            </Col>
          </Row>
        </Content>
        <Content>
          <div className="App-CardList">
            {!isMobile ?
              (<div>
                <Row type="flex">
                  <Col span="12">
                    <Card title={<FormattedMessage id={"CardTitle1"} />} >
                      <p className="App-Card-content">
                        <FormattedMessage id={"CardContent1"} />
                      </p>
                      <a href={latest[this.state.platform].url}><Button type="primary" icon="download"><FormattedMessage id={"CardAction1"} /></Button></a>
                    </Card>
                  </Col>

                  <Col span="12">
                    <Card title={<FormattedMessage id={"CardTitle2"} />} >
                      <p className="App-Card-content">
                        <FormattedMessage id={"CardContent2"} />
                      </p>
                      <Link to="about">
                        <Button type="primary" icon="plus-square-o"><FormattedMessage id={"CardAction2"} /></Button>
                      </Link>
                    </Card>
                  </Col>
                </Row>

                <Row type="flex">
                  <Col span="12">
                    <Card title={<FormattedMessage id={"CardTitle4"} />} >
                      <p className="App-Card-content">
                        <FormattedMessage id={"CardContent4"} />
                      </p>
                      <Timeline pending={<a href="#"><FormattedMessage id={"WillHaveFunctions"} /></a>}>
                        {realData.CardTimeLine4.map((item, i) => {
                          return <Timeline.Item key={i}>{item}</Timeline.Item>
                        })}
                      </Timeline>
                      <a href=""><Button id="Card4Button" type="primary" icon="heart"><FormattedMessage id={"CardAction4"} /></Button></a>
                    </Card>
                  </Col>
                  <Col span="12">
                    <Card title={<FormattedMessage id={"CardTitle3"} />} >
                      <p className="App-Card-content">
                        <FormattedMessage id={"CardContent3"} />
                      </p>
                      <Timeline>
                        <Timeline.Item>{stats.signups || 'loading..'} <FormattedMessage id="IsRegisted" /> </Timeline.Item>
                        <Timeline.Item>{stats.online || 'loading..'} <FormattedMessage id="IsPlaying" /> </Timeline.Item>
                      </Timeline>
                      <div className="MoeCubeProduct">
                        <img alt="MoeCubeProduct" width="100%" src={require('../public/moecube-product.png')} />
                      </div>
                      <a href=""><Button id="Card3Button" type="primary" icon="star"><FormattedMessage id={"CardAction3"} /></Button></a>
                    </Card>
                  </Col>
                </Row>


              </div>) : (<div>


                <Row>
                  <Col span="24">
                    <Card title={<FormattedMessage id={"CardTitle1"} />} >
                      <p className="App-Card-content">
                        <FormattedMessage id={"CardContent1"} />
                      </p>
                      <a href=""><Button type="primary" icon="download"><FormattedMessage id={"CardAction1"} /></Button></a>
                    </Card>
                  </Col>
                </Row>
                <Row>
                  <Col span="24">
                    <Card title={<FormattedMessage id={"CardTitle2"} />} >
                      <p className="App-Card-content">
                        <FormattedMessage id={"CardContent2"} />
                      </p>
                      <a href=""><Button type="primary" icon="plus-square-o"><FormattedMessage id={"CardAction2"} /></Button></a>
                    </Card>
                  </Col>
                </Row>
                <Row>
                  <Col span="24">
                    <Card title={<FormattedMessage id={"CardTitle4"} />} >
                      <p className="App-Card-content">
                        <FormattedMessage id={"CardContent4"} />
                      </p>
                      <Timeline pending={<a href="#"><FormattedMessage id={"CardAction4"} /></a>}>
                        {realData.CardTimeLine4.map((item, i) => {
                          return <Timeline.Item key={i}>{item}</Timeline.Item>
                        })}
                      </Timeline>
                      <a href=""><Button id="Card4Button" size="large" type="primary"><FormattedMessage id={"CardAction4"} /></Button></a>
                    </Card>
                  </Col>
                </Row>
                <Row>
                  <Col span="24">
                    <Card title={<FormattedMessage id={"CardTitle3"} />} >
                      <p className="App-Card-content">
                        <FormattedMessage id={"CardContent3"} />
                      </p>
                      <Timeline>
                        <Timeline.Item>{stats.signups || 'loading..'} 只萌新已加入萌卡</Timeline.Item>
                        <Timeline.Item>{stats.online || 'loading..'} 位爱的战士正在线游戏</Timeline.Item>
                      </Timeline>

                      <div className="MoeCubeProduct">
                        <img alt="MoeCubeProduct" width="100%" src={require('../public/moecube-product.png')} />
                      </div>

                      <a href=""><Button id="Card3Button" type="primary" icon="heart"><FormattedMessage id={"CardAction3"} /></Button></a>
                    </Card>
                  </Col>
                </Row>
              </div>)}
          </div>
        </Content>

        {!isMobile ?
          (<div>
            <Content className="App-Content2">
              <Col span="14">
                <p id="Welcome"><FormattedMessage id={"Welcome"} /></p>
                <a href={latest[this.state.platform].url}>
                  <Button id="downloadbot" type="primary" icon="download" size='large'>
                    <FormattedMessage id={"Download"} />
                  </Button>
                </a>
              </Col>
              <Col span="10">
                <p id="requirments"><FormattedMessage id={"SystemRequirements"} /></p>
              </Col>
            </Content>
          </div>) : (<div>
            <Content className="App-Content2">
              <Col span="24">
                <p id="Welcome"><FormattedMessage id={"Welcome"} /></p>
                <a href={latest[this.state.platform].url}>
                  <Button id="downloadbot" type="primary" icon="download" size='large'>
                    <FormattedMessage id={"Download"} />
                  </Button>
                </a>
                <p id="requirments"><FormattedMessage id={"SystemRequirements"} /></p>
              </Col>
            </Content>
          </div>)
        }



        <Footer>
          <div>
            <Dropdown overlay={menu} trigger={['click']}>
              {language === 'en-US' ?
                (<a className="ant-dropdown-link changelanguage" href="#">
                  <img alt="img" src={require('../public/flag-us.png')} />
                  &nbsp;English <Icon type="down" className="flag" />
                </a>) : (<a className="ant-dropdown-link changelanguage" href="#">
                  <img alt="img" src={require('../public/flag-cn.png')} />
                  &nbsp;中文 <Icon type="down" className="flag" />
                </a>)}
            </Dropdown>
          </div>
          © MoeCube 2017 all right reserved.
        </Footer>
      </Layout>
    )
  }
}

const DownLoadLink = ({ text, data = {} }) => {

  return (
    <a href={data.url} >{text}</a>
  )
}

