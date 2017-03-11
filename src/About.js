import React from 'react'
import enquire from 'enquire.js'

import { Layout } from 'antd'


import Nav from './Nav'

const { Header } = Layout

export default class About extends React.Component {
    constructor(props) {
        super(props)

        this.state = {
            isMobile: false,
            //stats: { signups: null, online: null },
            //latest: { win32: {}, drawin: {} },
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

        // const initState = {
        //     stats: {
        //         signups: await this.get_stats_signups(),
        //         online: await this.get_stats_online()
        //     }
        // }

        // const initLatest = {
        //     latest: {
        //         win32: await this.get_latest_win32(),
        //         drawin: await this.get_latest_drawin()
        //     }
        // }

        // this.setState(initState)
        // this.setState(initLatest)
    }

    render() {
        const { isMobile } = this.state // const { latest, isMobile, stats } = this.state
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
            </Layout>
        )
    }
}