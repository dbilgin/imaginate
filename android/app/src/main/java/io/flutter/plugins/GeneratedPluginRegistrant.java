package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.yangyxd.flutterpicker.FlutterPickerPlugin;
import io.flutter.plugins.imagepicker.ImagePickerPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    FlutterPickerPlugin.registerWith(registry.registrarFor("com.yangyxd.flutterpicker.FlutterPickerPlugin"));
    ImagePickerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.imagepicker.ImagePickerPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
