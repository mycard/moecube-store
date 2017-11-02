import 'core-js/shim'
import 'intl'
import 'intl/locale-data/jsonp/en.js'
import 'intl/locale-data/jsonp/zh-Hans.js'
import 'matchmedia-polyfill'
import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'
import About from './About'
import Translate from './Translate'
import './index.css'
import { Router, Route, browserHistory } from 'react-router'

const NotFound = () => <div>404</div>

class Index extends React.Component {

  render() {
    return (
      <Router history={browserHistory}>
      <Route path="/" component={App} />
      <Route path="about" component={About}/>
      <Route path="*" component={NotFound}/>
    </Router>
    )
  }
}



ReactDOM.render(
  <Translate Template={<Index/>} />,
  document.getElementById('root')
)
