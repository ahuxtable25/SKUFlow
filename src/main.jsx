import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import WaitlistPage from './WaitlistPage.jsx'

const path = window.location.pathname.replace(/\/+$/, '')
const isWaitlist = path === '/waitlist'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    {isWaitlist ? <WaitlistPage /> : <App />}
  </React.StrictMode>,
)
