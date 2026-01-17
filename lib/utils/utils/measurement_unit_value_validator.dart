import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/utils/constants/app_texts.dart';

abstract class MeasurementUnitValueValidator {
  
  
  
  static void validate({
    required HealthDataType forDataType,
    required MeasurementUnit value,
  }) {
    // Validate based on the parsed measurement unit type
    switch (value) {
      case Number():
        _validateNumber(value);
      case Percentage():
        _validatePercentage(value);
      case Mass():
        _validateMass(value);
      case Length():
        _validateLength(value);
      case Temperature():
        _validateTemperature(value);
      case BloodGlucose():
        _validateBloodGlucose(value);
      case Pressure():
        _validatePressure(value);
      case Energy():
        _validateEnergy(value);
      case Velocity():
        _validateVelocity(value);
      case Volume():
        _validateVolume(value);
      case Power():
        _validatePower(value);
      case TimeDuration():
        _validateTimeDuration(value);
      case Frequency():
        _validateFrequency(value);
    }
  }

  
  
  
  
  
  static void _validateNumber(Number value) {
    if (value.value < 0) {
      throw ArgumentError(AppTexts.countMustBeNonNegative);
    }
  }

  
  
  
  
  
  static void _validatePercentage(Percentage value) {
    final wholeValue = value.asWhole;
    if (wholeValue < 0 || wholeValue > 100) {
      throw ArgumentError(AppTexts.bodyFatPercentageMustBeBetween0And100);
    }
  }

  
  
  
  
  
  static void _validateMass(Mass value) {
    if (value.inKilograms <= 0) {
      throw ArgumentError(AppTexts.pleaseEnterValidNumber);
    }
  }

  
  
  
  
  
  static void _validateLength(Length value) {
    if (value.inMeters <= 0) {
      throw ArgumentError(AppTexts.pleaseEnterValidNumber);
    }
  }

  
  
  
  static void _validateTemperature(Temperature value) {
    // No validation constraints for temperature
  }

  
  
  
  
  
  static void _validateBloodGlucose(BloodGlucose value) {
    if (value.inMilligramsPerDeciliter <= 0) {
      throw ArgumentError(AppTexts.pleaseEnterValidNumber);
    }
  }

  
  
  
  
  
  static void _validatePressure(Pressure value) {
    if (value.inMillimetersOfMercury <= 0) {
      throw ArgumentError(AppTexts.pleaseEnterValidNumber);
    }
  }

  
  
  
  
  
  static void _validateEnergy(Energy value) {
    if (value.inKilocalories <= 0) {
      throw ArgumentError(AppTexts.pleaseEnterValidNumber);
    }
  }

  
  
  
  
  
  static void _validateVelocity(Velocity value) {
    if (value.inMetersPerSecond <= 0) {
      throw ArgumentError(AppTexts.pleaseEnterValidNumber);
    }
  }

  
  
  
  
  
  static void _validateVolume(Volume value) {
    if (value.inLiters <= 0) {
      throw ArgumentError(AppTexts.pleaseEnterValidNumber);
    }
  }

  
  
  
  
  
  static void _validatePower(Power value) {
    if (value.inWatts <= 0) {
      throw ArgumentError(AppTexts.pleaseEnterValidNumber);
    }
  }

  
  
  
  
  
  static void _validateTimeDuration(TimeDuration value) {
    if (value.inSeconds <= 0) {
      throw ArgumentError(AppTexts.pleaseEnterValidNumber);
    }
  }

  
  
  
  
  
  static void _validateFrequency(Frequency value) {
    if (value.inPerMinute <= 0) {
      throw ArgumentError(AppTexts.pleaseEnterValidNumber);
    }
  }
}
