import React from 'react'
import { IntlProvider, addLocaleData } from 'react-intl'
import en from 'react-intl/locale-data/en'
import zh from 'react-intl/locale-data/zh'
import localeData from '../i18n.json'


addLocaleData([...en, ...zh])
const language =  localStorage.getItem('language') || navigator.language || (navigator.languages && navigator.languages[0]) || navigator.userLanguage || navigator.browserLanguage || 'zh-CN' ;

const languageWithoutRegionCode = language.toLowerCase().split(/[_-]+/)[0];

const messages = localeData[languageWithoutRegionCode] || localeData[language] || localeData.zh;

export default class Translate extends React.Component {

    render() {
    	return (
	    	<IntlProvider locale={ language } messages={ messages }>
					{React.cloneElement(this.props.Template, {language})}
	    	</IntlProvider>
	    )
    }
}