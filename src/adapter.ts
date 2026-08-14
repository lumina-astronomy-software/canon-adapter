/** Identity this process presents to a Lumina orchestrator. */
export const ADAPTER_ID = 'canon'
export const ADAPTER_NAME = 'Canon DSLR'
export const PROTOCOL = 'lumina.camera.v1'
export const ADAPTER_VERSION = '0.1.0'

export const STREAM_PATH = process.env.STREAM_PATH || 'canon'

export interface AdapterManifest {
  id: typeof ADAPTER_ID
  name: typeof ADAPTER_NAME
  version: string
  protocol: typeof PROTOCOL
  streamPath: string
  capabilities: {
    liveView: boolean
    stillCapture: boolean
    timelapse: boolean
    exposure: boolean
    focus: boolean
  }
}

export const MANIFEST: AdapterManifest = {
  id: ADAPTER_ID,
  name: ADAPTER_NAME,
  version: ADAPTER_VERSION,
  protocol: PROTOCOL,
  streamPath: STREAM_PATH,
  capabilities: {
    liveView: true,
    stillCapture: true,
    timelapse: true,
    exposure: true,
    focus: false
  }
}
