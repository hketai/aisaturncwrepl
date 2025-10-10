import makeWASocket, { DisconnectReason, useMultiFileAuthState, fetchLatestBaileysVersion } from '@whiskeysockets/baileys';
import { Boom } from '@hapi/boom';
import axios from 'axios';
import QRCode from 'qrcode';
import { existsSync, mkdirSync } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SESSIONS_DIR = path.join(__dirname, '../sessions');

export class ConnectionManager {
  constructor(logger, webhookBaseUrl) {
    this.logger = logger;
    this.webhookBaseUrl = webhookBaseUrl;
    this.connections = new Map();
    
    if (!existsSync(SESSIONS_DIR)) {
      mkdirSync(SESSIONS_DIR, { recursive: true });
    }
  }

  async connect(channelId, webhookUrl) {
    if (this.connections.has(channelId)) {
      return { status: 'already_connected', qr: null };
    }

    const sessionPath = path.join(SESSIONS_DIR, `channel_${channelId}`);
    if (!existsSync(sessionPath)) {
      mkdirSync(sessionPath, { recursive: true });
    }

    const { state, saveCreds } = await useMultiFileAuthState(sessionPath);
    const { version } = await fetchLatestBaileysVersion();

    let qrData = null;

    const sock = makeWASocket({
      version,
      auth: state,
      printQRInTerminal: false,
      getMessage: async () => ({ conversation: '' })
    });

    sock.ev.on('creds.update', saveCreds);

    sock.ev.on('connection.update', async (update) => {
      const { connection, lastDisconnect, qr } = update;

      if (qr) {
        qrData = await QRCode.toDataURL(qr);
        this.logger.info({ channelId }, 'QR code generated');
        
        const conn = this.connections.get(channelId);
        if (conn) {
          conn.qrCode = qrData;
        }
        
        await this.sendWebhook(webhookUrl, {
          event: 'qr.generated',
          channel_id: channelId,
          qr_code: qrData
        });
      }

      if (connection === 'close') {
        const shouldReconnect = (lastDisconnect?.error instanceof Boom)
          && lastDisconnect.error.output?.statusCode !== DisconnectReason.loggedOut;

        this.logger.warn({ channelId, shouldReconnect }, 'Connection closed');
        this.connections.delete(channelId);

        await this.sendWebhook(webhookUrl, {
          event: 'connection.closed',
          channel_id: channelId,
          should_reconnect: shouldReconnect
        });

        if (shouldReconnect) {
          setTimeout(() => this.connect(channelId, webhookUrl), 3000);
        }
      } else if (connection === 'open') {
        this.logger.info({ channelId }, 'Connection established');
        await this.sendWebhook(webhookUrl, {
          event: 'connection.open',
          channel_id: channelId
        });
      }
    });

    sock.ev.on('messages.upsert', async ({ messages, type }) => {
      if (type !== 'notify') return;

      const msg = messages[0];
      if (msg.key.fromMe) return;

      this.logger.info({ channelId, messageId: msg.key.id }, 'Incoming message');

      await this.sendWebhook(webhookUrl, {
        event: 'message.received',
        channel_id: channelId,
        message: {
          id: msg.key.id,
          from: msg.key.remoteJid,
          timestamp: msg.messageTimestamp,
          text: msg.message?.conversation || msg.message?.extendedTextMessage?.text,
          media_type: this.getMediaType(msg.message)
        }
      });
    });

    this.connections.set(channelId, { sock, sessionPath, webhookUrl });

    return { status: 'connecting', qr: qrData };
  }

  async disconnect(channelId) {
    const conn = this.connections.get(channelId);
    if (!conn) return { status: 'not_found' };

    try {
      await conn.sock.logout();
      this.connections.delete(channelId);
      this.logger.info({ channelId }, 'Disconnected successfully');
      return { status: 'disconnected' };
    } catch (error) {
      this.logger.error({ channelId, error }, 'Disconnect failed');
      return { status: 'error', message: error.message };
    }
  }

  async sendMessage(channelId, jid, text) {
    const conn = this.connections.get(channelId);
    if (!conn) throw new Error('Channel not connected');

    const response = await conn.sock.sendMessage(jid, { text });
    return { messageId: response.key.id };
  }

  async sendMedia(channelId, jid, url, caption, mediaType) {
    const conn = this.connections.get(channelId);
    if (!conn) throw new Error('Channel not connected');

    const content = { [mediaType]: { url } };
    if (caption) content.caption = caption;

    const response = await conn.sock.sendMessage(jid, content);
    return { messageId: response.key.id };
  }

  getStatus(channelId) {
    const conn = this.connections.get(channelId);
    if (!conn) return { connected: false };

    return {
      connected: true,
      authenticated: conn.sock.authState?.creds?.me?.id ? true : false
    };
  }

  async getQR(channelId) {
    const conn = this.connections.get(channelId);
    if (!conn) return null;
    
    return conn.qrCode || null;
  }

  getMediaType(message) {
    if (message?.imageMessage) return 'image';
    if (message?.videoMessage) return 'video';
    if (message?.audioMessage) return 'audio';
    if (message?.documentMessage) return 'document';
    return 'text';
  }

  async sendWebhook(url, data) {
    try {
      await axios.post(url, data, {
        headers: { 'Content-Type': 'application/json' },
        timeout: 5000
      });
    } catch (error) {
      this.logger.error({ url, error: error.message }, 'Webhook delivery failed');
    }
  }
}
