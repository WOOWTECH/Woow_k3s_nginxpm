{{/*
Helper templates for the nginxpm chart.
Resource names, labels and selectors are fixed (not derived from the release
name): existing Proxy Hosts / SSL data reference the Service by this exact
name, and changing a selector or pod-template label would restart the pod.
*/}}

{{- /*
Target namespace. Falls back to the release namespace so that `-n` ALWAYS
controls object placement: a values-file `namespace.name` that silently beat
`-n` is how a rehearsal once wrote Helm ownership annotations onto a live
production Deployment. Set namespace.name only to place objects somewhere
other than the release namespace, and never in an instance-values file.
*/ -}}
{{- define "nginxpm.ns" -}}
{{ .Values.namespace.name | default .Release.Namespace }}
{{- end -}}

{{/*
Base name for every object: the Deployment, the Service, both PVCs, the pod
label and the selector. Fixed per instance rather than derived from the release
name, because the selector is immutable on a live Deployment and existing Proxy
Hosts reference the Service by this exact name. A second instance of this chart
runs as `npm` in another namespace, which is why this is a value at all.
*/}}
{{- define "nginxpm.name" -}}
{{ .Values.baseName }}
{{- end -}}

{{/* `annotations:` block with the keep policy, or nothing. */}}
{{- define "nginxpm.keepAnnotations" -}}
{{- if .Values.keepOnUninstall -}}
annotations:
  helm.sh/resource-policy: keep
{{- end -}}
{{- end -}}
