import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'
import Translate from './Translate'
import './index.css'




ReactDOM.render(
  <Translate Template={<App/>} />,
  document.getElementById('root')
)
