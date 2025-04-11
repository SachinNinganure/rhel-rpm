#!/bin/bash
#Sachin Ninganure

LOCAL_RPM_NM="/home/sninganu/rhel_verification/core/NetworkManager-1.52.0-1.rhel84142.el9_6.x86_64.rpm"
LOCAL_RPM_CS="/home/sninganu/rhel_verification/core/NetworkManager-cloud-setup-1.52.0-1.rhel84142.el9_6.x86_64.rpm"
LOCAL_RPM_OVS="/home/sninganu/rhel_verification/core/NetworkManager-ovs-1.52.0-1.rhel84142.el9_6.x86_64.rpm"
LOCAL_RPM_TM="/home/sninganu/rhel_verification/core/NetworkManager-team-1.52.0-1.rhel84142.el9_6.x86_64.rpm"
LOCAL_RPM_TUI="/home/sninganu/rhel_verification/core/NetworkManager-tui-1.52.0-1.rhel84142.el9_6.x86_64.rpm"
LOCAL_RPM_LIB="/home/sninganu/rhel_verification/core/NetworkManager-libnm-1.52.0-1.rhel84142.el9_6.x86_64.rpm"

TARGET_DIR="/host/home/core"

REPLACE_NM="/home/core/NetworkManager-1.52.0-1.rhel84142.el9_6.x86_64.rpm"
REPLACE_CS="/home/core/NetworkManager-cloud-setup-1.52.0-1.rhel84142.el9_6.x86_64.rpm"
REPLACE_OVS="/home/core/NetworkManager-ovs-1.52.0-1.rhel84142.el9_6.x86_64.rpm"
REPLACE_TM="/home/core/NetworkManager-team-1.52.0-1.rhel84142.el9_6.x86_64.rpm"
REPLACE_TUI="/home/core/NetworkManager-tui-1.52.0-1.rhel84142.el9_6.x86_64.rpm"
REPLACE_LIB="/home/core/NetworkManager-libnm-1.52.0-1.rhel84142.el9_6.x86_64.rpm"

for NODE in $(oc get nodes -o jsonpath='{.items[*].metadata.name}'); do
  echo "Processing node: $NODE"

  oc debug "node/${NODE}" \
    -- chroot /host /bin/sh -c "sleep infinity" & >/dev/null 2>&1

  echo "Waiting for debug pod to start..."
  while ! oc get pod | grep -q Running; do
    sleep 2
  done
  DEBUG_POD_NAME=$(oc get pods -o jsonpath='{.items[*].metadata.name}')
  echo "$DEBUG_POD_NAME"
echo "Copying Network manager RPM"
 if ! oc cp "${LOCAL_RPM_NM}" "${DEBUG_POD_NAME}:${TARGET_DIR}"; then
    echo "Error: Failed to copy RPM to node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi

echo "Copying Network cloud RPM"
 if ! oc cp "${LOCAL_RPM_CS}" "${DEBUG_POD_NAME}:${TARGET_DIR}"; then
    echo "Error: Failed to copy RPM to node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi

echo "Copying Network OVS RPM"
 if ! oc cp "${LOCAL_RPM_OVS}" "${DEBUG_POD_NAME}:${TARGET_DIR}"; then
    echo "Error: Failed to copy RPM to node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi

echo "Copying Network Team RPM"
 if ! oc cp "${LOCAL_RPM_TM}" "${DEBUG_POD_NAME}:${TARGET_DIR}"; then
    echo "Error: Failed to copy RPM to node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi
  
echo "Copying Network TUI RPM"
 if ! oc cp "${LOCAL_RPM_TUI}" "${DEBUG_POD_NAME}:${TARGET_DIR}"; then
    echo "Error: Failed to copy RPM to node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi

echo "Copying Network Library RPM"
 if ! oc cp "${LOCAL_RPM_LIB}" "${DEBUG_POD_NAME}:${TARGET_DIR}"; then
    echo "Error: Failed to copy RPM to node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi

echo "replace Network Manager library"
 if ! oc exec "${DEBUG_POD_NAME}" -- chroot /host /bin/sh -c \
    "rpm-ostree override replace ${REPLACE_NM}"; then
    echo "Error: Package operation failed on node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi

echo "replace cloud setup library"
 if ! oc exec "${DEBUG_POD_NAME}" -- chroot /host /bin/sh -c \
    "rpm-ostree override replace ${REPLACE_CS}"; then
    echo "Error: Package operation failed on node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi

echo "replace OVS library"
 if ! oc exec "${DEBUG_POD_NAME}" -- chroot /host /bin/sh -c \
    "rpm-ostree override replace ${REPLACE_OVS}"; then
    echo "Error: Package operation failed on node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi

echo "replace TM library"
 if ! oc exec "${DEBUG_POD_NAME}" -- chroot /host /bin/sh -c \
    "rpm-ostree override replace ${REPLACE_TM}"; then
    echo "Error: Package operation failed on node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi
 
echo "replace TUI library"
 if ! oc exec "${DEBUG_POD_NAME}" -- chroot /host /bin/sh -c \
    "rpm-ostree override replace ${REPLACE_TUI}"; then
    echo "Error: Package operation failed on node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi
 
echo "replace Network libnm library"
 if ! oc exec "${DEBUG_POD_NAME}" -- chroot /host /bin/sh -c \
    "rpm-ostree override replace ${REPLACE_LIB}"; then
    echo "Error: Package operation failed on node ${NODE}"
    oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1
    continue
  fi

  oc exec "${DEBUG_POD_NAME}" -- chroot /host /bin/sh -c "nohup systemctl reboot &" >/dev/null 2>&1

  oc delete pod "${DEBUG_POD_NAME}" --force --grace-period=0 >/dev/null 2>&1

  sleep 60s
  echo "Waiting for node ${NODE} to reboot..."
  until oc get node "${NODE}" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q True; do
    sleep 10
  done
  echo "Node ${NODE} reboot completed."
done
