/// Call Screen for Audio/Video Calls
library;

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
 import '../../../data/models/models.dart';

class CallScreen extends StatefulWidget {
  final String callId;
  final String otherUserId;
  final bool isCaller;
  final bool isVideo;
  final String? otherUserName;
  final String? otherUserAvatar;

  const CallScreen({
    super.key,
    required this.callId,
    required this.otherUserId,
    required this.isCaller,
    this.isVideo = true,
    this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  final bool _isSpeakerOn = true;
  final CallStatus _status = CallStatus.initiated;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _connectCall();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connectCall() {
    // TODO: Connect to WebRTC service
    if (widget.isCaller) {
      // initiate call
    } else {
      // answer call
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _endCall() {
    Navigator.pop(context);
    // TODO: Signal end call
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video (Full Screen)
          if (widget.isVideo)
            Positioned.fill(
              child: RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),

          // Calling Status / Avatar (if video off or audio call)
          if (!widget.isVideo || _status != CallStatus.ongoing)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundImage: widget.otherUserAvatar != null
                          ? NetworkImage(widget.otherUserAvatar!)
                          : null,
                      child: widget.otherUserAvatar == null
                          ? Text(
                              (widget.otherUserName ?? '?')[0].toUpperCase(),
                              style: GoogleFonts.inter(fontSize: 48),
                            )
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.otherUserName ?? 'Unknown User',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status == CallStatus.initiated
                          ? (widget.isCaller ? 'Calling...' : 'Incoming Call')
                          : 'Connected',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Local Video (PiP)
          if (widget.isVideo && _status == CallStatus.ongoing)
            Positioned(
              right: 16,
              top: 48,
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),

          // Controls
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mic Toggle
                _buildControlBtn(
                  icon: _isMicMuted ? Icons.mic_off : Icons.mic,
                  color: _isMicMuted ? Colors.white : Colors.white24,
                  onTap: () => setState(() => _isMicMuted = !_isMicMuted),
                ),

                // End Call
                _buildControlBtn(
                  icon: Icons.call_end,
                  color: Colors.red,
                  size: 64,
                  onTap: _endCall,
                ),

                // Camera Toggle (if video)
                if (widget.isVideo)
                  _buildControlBtn(
                    icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                    color: _isCameraOff ? Colors.white : Colors.white24,
                    onTap: () => setState(() => _isCameraOff = !_isCameraOff),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 56,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}
