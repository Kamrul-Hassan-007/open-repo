#!/bin/bash

if ip a show CloudflareWARP | grep -q "inet "; then
  echo '{"text": " WARP", "tooltip": "Cloudflare Activated"}'
else
  echo '{"text": " ", "tooltip": "Cloudflare Diactivated"}'
fi

