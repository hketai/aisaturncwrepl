#!/usr/bin/env node

const { default: makeWASocket, DisconnectReason, useMultiFileAuthState, fetchLatestBaileysVersion } = require('@whiskeysockets/baileys');
const { Boom } = require('@hapi/boom');
const readline = require('readline');
const QRCode = require('qrcode');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

class BaileysBridge {
  constructor() {
    this.sock = null;
    this.authState = null;
  }

  async connect(sessionPath) {
    try {
      const { state, saveCreds } = await useMultiFileAuthState(sessionPath);
      const { version } = await fetchLatestBaileysVersion();
      
      this.sock = makeWASocket({
        version,
        auth: state,
        printQRInTerminal: false,
        getMessage: async (key) => ({ conversation: '' })
      });

      this.sock.ev.on('creds.update', saveCreds);

      this.sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update;
        
        if (qr) {
          const qrBase64 = await QRCode.toDataURL(qr);
          this.sendMessage({ type: 'qr', data: qrBase64 });
        }
        
        if (connection === 'close') {
          const shouldReconnect = (lastDisconnect?.error instanceof Boom) 
            && lastDisconnect.error.output?.statusCode !== DisconnectReason.loggedOut;
          
          this.sendMessage({ 
            type: 'connection_update', 
            status: 'close',
            shouldReconnect 
          });
          
          if (shouldReconnect) {
            await this.connect(sessionPath);
          }
        } else if (connection === 'open') {
          this.sendMessage({ type: 'connection_update', status: 'open' });
        }
      });

      this.sock.ev.on('messages.upsert', async ({ messages, type }) => {
        if (type !== 'notify') return;
        
        const msg = messages[0];
        if (msg.key.fromMe) return;
        
        this.sendMessage({
          type: 'message',
          data: {
            id: msg.key.id,
            from: msg.key.remoteJid,
            message: msg.message?.conversation || msg.message?.extendedTextMessage?.text,
            timestamp: msg.messageTimestamp
          }
        });
      });

      this.sendMessage({ type: 'ready', status: 'initialized' });
      
    } catch (error) {
      this.sendMessage({ type: 'error', message: error.message });
    }
  }

  async sendTextMessage(jid, text) {
    try {
      const response = await this.sock.sendMessage(jid, { text });
      this.sendMessage({ type: 'send_success', messageId: response.key.id });
    } catch (error) {
      this.sendMessage({ type: 'send_error', message: error.message });
    }
  }

  async sendMediaMessage(jid, url, caption, mediaType) {
    try {
      const content = { [mediaType]: { url } };
      if (caption) content.caption = caption;
      
      const response = await this.sock.sendMessage(jid, content);
      this.sendMessage({ type: 'send_success', messageId: response.key.id });
    } catch (error) {
      this.sendMessage({ type: 'send_error', message: error.message });
    }
  }

  sendMessage(data) {
    console.log(JSON.stringify(data));
  }

  async disconnect() {
    if (this.sock) {
      await this.sock.logout();
      this.sock = null;
    }
    process.exit(0);
  }
}

const bridge = new BaileysBridge();

rl.on('line', async (line) => {
  try {
    const command = JSON.parse(line);
    
    switch (command.action) {
      case 'connect':
        await bridge.connect(command.sessionPath);
        break;
      case 'send_text':
        await bridge.sendTextMessage(command.jid, command.text);
        break;
      case 'send_media':
        await bridge.sendMediaMessage(command.jid, command.url, command.caption, command.mediaType);
        break;
      case 'disconnect':
        await bridge.disconnect();
        break;
    }
  } catch (error) {
    bridge.sendMessage({ type: 'error', message: error.message });
  }
});

rl.on('close', () => {
  bridge.disconnect();
});
