# Changes

## v0.1.1 (not released yet)

- `setup.sh`: the default template is now `com.unity.template.urp-blank` (`UNITY_TEMPLATE` in `sessions.conf`). In
  v0.1.0, `setup.sh` stopped at once with "Could not resolve default template", because the Unity CLI has no default
  template when the Editor has no 3D template (Unity 6000.6 has only the URP blank and the 2D templates).
- `setup.sh`: when the Unity CLI is not there or fails, it falls back to the Editor with `-createProject`. Before the
  CLI runs, it warns when the Editor does not have the template, and it lists the templates that the Editor has.
- README: the status now lists the checks with Unity (setup, the quick tier, the compile check, a development build).

## v0.1.0 (21 October 2026)

- The first public version.
