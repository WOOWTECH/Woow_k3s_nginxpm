{{/*
Helper templates for the nginxpm chart.
Resource names, labels and selectors are fixed (not derived from the release
name): existing Proxy Hosts / SSL data reference the Service by this exact
name, and changing a selector or pod-template label would restart the pod.
*/}}

{{- define "nginxpm.ns" -}}
{{ .Values.namespace.name }}
{{- end -}}

{{/* `annotations:` block with the keep policy, or nothing. */}}
{{- define "nginxpm.keepAnnotations" -}}
{{- if .Values.keepOnUninstall -}}
annotations:
  helm.sh/resource-policy: keep
{{- end -}}
{{- end -}}
