#!/bin/sh

# /bin/sh into given namespace and pod
function kubebash { kubectl exec -n $1 $2 -it -- /bin/sh; }