{{flutter_js}}
{{flutter_build_config}}

// The HTML reading view is available to every visitor, with or without JS.
// Keep the live Flutter app as the default; text view avoids loading its engine.
if (new URLSearchParams(location.search).get('view') !== 'text') {
  const host = document.getElementById('flutter-host');
  const config = host ? {hostElement: host, canvasKitBaseUrl: '/canvaskit/'} : {};
  _flutter.loader.load({
    config,
    onEntrypointLoaded: async function (engineInitializer) {
      try {
        const appRunner = await engineInitializer.initializeEngine(config);
        await appRunner.runApp();
        document.dispatchEvent(new Event('nib-app-ready'));
      } catch (error) {
        document.dispatchEvent(new Event('nib-app-failed'));
        console.error('Nib could not start the interactive view.', error);
      }
    },
  });
}
