#!/bin/bash
su www-data <<'EOF'
export PATH=$PATH:/nodejs/bin
/bin/bash
EOF
