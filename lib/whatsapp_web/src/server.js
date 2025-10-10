import express from 'express';
import pino from 'pino';
import { ConnectionManager } from './connection-manager.js';

const app = express();
const PORT = process.env.WHATSAPP_WEB_PORT || 3030;
const WEBHOOK_BASE_URL = process.env.RAILS_BASE_URL || 'http://localhost:5000';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: {
    target: 'pino-pretty',
    options: { colorize: true }
  }
});

const manager = new ConnectionManager(logger, WEBHOOK_BASE_URL);

app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Connect a WhatsApp channel
app.post('/channels/:channelId/connect', async (req, res) => {
  try {
    const { channelId } = req.params;
    const { webhookUrl } = req.body;

    if (!webhookUrl) {
      return res.status(400).json({ error: 'webhookUrl is required' });
    }

    const result = await manager.connect(channelId, webhookUrl);
    res.json(result);
  } catch (error) {
    logger.error({ error }, 'Connect failed');
    res.status(500).json({ error: error.message });
  }
});

// Disconnect a channel
app.post('/channels/:channelId/disconnect', async (req, res) => {
  try {
    const { channelId } = req.params;
    const result = await manager.disconnect(channelId);
    res.json(result);
  } catch (error) {
    logger.error({ error }, 'Disconnect failed');
    res.status(500).json({ error: error.message });
  }
});

// Get connection status
app.get('/channels/:channelId/status', (req, res) => {
  try {
    const { channelId } = req.params;
    const status = manager.getStatus(channelId);
    res.json(status);
  } catch (error) {
    logger.error({ error }, 'Status check failed');
    res.status(500).json({ error: error.message });
  }
});

// Send text message
app.post('/channels/:channelId/messages/text', async (req, res) => {
  try {
    const { channelId } = req.params;
    const { to, text } = req.body;

    if (!to || !text) {
      return res.status(400).json({ error: 'to and text are required' });
    }

    const result = await manager.sendMessage(channelId, to, text);
    res.json(result);
  } catch (error) {
    logger.error({ error }, 'Send message failed');
    res.status(500).json({ error: error.message });
  }
});

// Send media message
app.post('/channels/:channelId/messages/media', async (req, res) => {
  try {
    const { channelId } = req.params;
    const { to, url, caption, mediaType } = req.body;

    if (!to || !url || !mediaType) {
      return res.status(400).json({ error: 'to, url, and mediaType are required' });
    }

    const result = await manager.sendMedia(channelId, to, url, caption, mediaType);
    res.json(result);
  } catch (error) {
    logger.error({ error }, 'Send media failed');
    res.status(500).json({ error: error.message });
  }
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received, shutting down gracefully');
  process.exit(0);
});

app.listen(PORT, () => {
  logger.info({ port: PORT }, 'WhatsApp Web service started');
});
