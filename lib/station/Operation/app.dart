// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:manageon/station/Operation/main_scaffold.dart';


// class BaronCitrusApp extends StatelessWidget {
//   const BaronCitrusApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       // locale: const Locale('ar'),
//       // supportedLocales: const [Locale('ar')],
//       builder: (context, child) {
//         return Directionality(
//           textDirection: TextDirection.rtl,
//           child: child!,
//         );
//       },
//       theme: ThemeData(
//         useMaterial3: true,
//         textTheme: GoogleFonts.cairoTextTheme(),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF059669),
//         ),
//       ),
//       home: const MainScaffold(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manageon/station/Operation/main_scaffold.dart';


class BaronCitrusApp extends StatelessWidget {
  const BaronCitrusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // // ✅ اللغة
      // locale: const Locale('ar'),
      // supportedLocales: const [
      //   Locale('ar'),
      //   Locale('en'),
      // ],

      // ✅ أهم جزء ناقص عندك
      localizationsDelegates: const [
        // GlobalMaterialLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate,
        // GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF059669),
        ),
      ),

      home: const MainScaffold(),
    );
  }
}
