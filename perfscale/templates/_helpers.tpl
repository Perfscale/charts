{{/*
Expand the name of the chart.
*/}}
{{- define "perfscale.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "perfscale.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "perfscale.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "perfscale.labels" -}}
helm.sh/chart: {{ include "perfscale.chart" . }}
{{ include "perfscale.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "perfscale.selectorLabels" -}}
app.kubernetes.io/name: {{ include "perfscale.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
The engine image, flavor suffix included:
ghcr.io/perfscale/perfscale:<tag|appVersion>[-flavor]
*/}}
{{- define "perfscale.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- $flavor := .Values.image.flavor -}}
{{- printf "%s:%s%s" .Values.image.repository $tag (ternary (printf "-%s" $flavor) "" (ne $flavor "")) }}
{{- end }}

{{/*
The ConfigMap the scenario is read from.
*/}}
{{- define "perfscale.scenarioConfigMap" -}}
{{- .Values.scenario.existingConfigMap | default (printf "%s-scenario" (include "perfscale.fullname" .)) }}
{{- end }}

{{/*
The Pod spec shared by the one-shot Job and the CronJob's jobTemplate.
*/}}
{{- define "perfscale.podSpec" -}}
restartPolicy: Never
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.podSecurityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
containers:
  - name: perfscale
    image: {{ include "perfscale.image" . }}
    imagePullPolicy: {{ .Values.image.pullPolicy }}
    workingDir: /work
    args:
      - run
      - -f
      - /scenario/{{ .Values.scenario.testKey }}
      {{- if .Values.scenario.config }}
      - -c
      - /scenario/{{ .Values.scenario.configKey }}
      {{- end }}
      {{- range .Values.extraArgs }}
      - {{ . | quote }}
      {{- end }}
    {{- if or .Values.cache.enabled .Values.env }}
    env:
      {{- if .Values.cache.enabled }}
      - name: PERFSCALE_CACHE_DIR
        value: /var/lib/perfscale/cache
      {{- end }}
      {{- with .Values.env }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
    {{- end }}
    {{- with .Values.securityContext }}
    securityContext:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.resources }}
    resources:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    volumeMounts:
      - name: scenario
        mountPath: /scenario
        readOnly: true
      - name: work
        mountPath: /work
      {{- if .Values.cache.enabled }}
      - name: library-cache
        mountPath: /var/lib/perfscale/cache
      {{- end }}
volumes:
  - name: scenario
    configMap:
      name: {{ include "perfscale.scenarioConfigMap" . }}
  - name: work
    emptyDir: {}
  {{- if .Values.cache.enabled }}
  - name: library-cache
    persistentVolumeClaim:
      claimName: {{ .Values.cache.existingClaim | default (printf "%s-library-cache" (include "perfscale.fullname" .)) }}
  {{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
The Job spec shared by the one-shot Job and the CronJob's jobTemplate.
*/}}
{{- define "perfscale.jobSpec" -}}
backoffLimit: {{ .Values.backoffLimit }}
{{- with .Values.ttlSecondsAfterFinished }}
ttlSecondsAfterFinished: {{ . }}
{{- end }}
{{- with .Values.activeDeadlineSeconds }}
activeDeadlineSeconds: {{ . }}
{{- end }}
template:
  metadata:
    labels:
      {{- include "perfscale.labels" . | nindent 6 }}
  spec:
    {{- include "perfscale.podSpec" . | nindent 4 }}
{{- end }}
