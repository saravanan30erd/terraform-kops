{{- define "wordpress.release_labels" }}
app: {{ .Chart.Name }}
version: {{ .Chart.Version }}
release: {{ .Release.Name }}
{{- end }}
