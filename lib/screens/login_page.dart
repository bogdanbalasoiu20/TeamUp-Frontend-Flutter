import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/utils/app_colors.dart';

class LoginScreen extends StatelessWidget{
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context){
    final size = MediaQuery.of(context).size;// afla dimnesiunea ecranului

      return Scaffold(
        body: Stack(//folosesc stack pentru a pune unul peste altul fundalul,titlul, containerul si footer-ul
          children:[
            Container(
              decoration: BoxDecoration(  //clasa care imi permite sa stilizez un container
                gradient: LinearGradient(
                  colors:[
                    const Color(0xFF003B2F),
                    AppColors.primaryGreenDark,
                    AppColors.primaryGreenLight,
                  ],
                  begin: Alignment.topCenter,  //gradientul se face de sus in jos
                  end: Alignment.bottomCenter
                ),
                image: const DecorationImage(  //adaug imaginea mea peste gradient
                image: AssetImage("lib/images/football_field.png"),
                fit: BoxFit.cover,
                opacity: 0.25,
              ),
            ),
            ),

            //Titlul
            Padding( //widget pentru spatiere interioara intre text si margini
              padding: const EdgeInsets.fromLTRB(28,80,28,0),  //spatiere in jurul textului
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,  //aliniere la stanga
                children: const[

                  //Titlul mare
                  Text(
                    "Hello",
                    style: TextStyle(
                      fontSize:38,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    )
                  ),

                  SizedBox(height: 6),

                  //Subtitlu
                  Text(
                    "Sign in",
                    style:TextStyle(
                      fontSize: 22,
                      color: Colors.white70
                    )
                  )

                ]

              )
            ),

            //Containerul alb
            Positioned( //control de pozitionare a containerului, widget care imi permite sa pun un widget intr-o pozitie exacta(top, bottom, left, right), doar daca se afla intr-un Stack
              top: size.height*0.27,  //specific distanta fata de margini
              left:0,
              right:0,
              bottom:0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),

                //decorarea containerului
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft:Radius.circular(36),
                    topRight: Radius.circular(36)
                  )
                ),

                //contimutul containerului(emailOrUsername, password, buton)
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height:8),

                    const BehanceUnderlineInput(
                      label:"Username/Email",
                      rightIcon: Icons.check
                    ),

                    const SizedBox(height:24),

                    const BehanceUnderlineInput(
                        label: "Password",
                        isPassword: true
                    ),

                    const SizedBox(height:14),

                    //Forh=got password
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize:14,
                          color: Colors.grey.shade600,
                        )
                      )
                    ),

                    const SizedBox(height:36),

                    //Buton Sign in
                    GestureDetector(
                      //actiune la tap
                      onTap:(){},
                      child:Container(
                        height:50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              const Color(0xFF003B2F),
                              AppColors.primaryGreenDark,
                              AppColors.primaryGreenLight,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight
                        ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                          child: Text(
                            "SIGN IN",
                            style:TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            )
                          )
                        )
                      )
                    )
                  ],
                )
              )

            ),

            //SIGN UP
            Positioned(
              bottom: 24,
              right: 26,
              child: Row(
                children:[
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700
                    )
                  ),

                  const SizedBox(width: 5),

                  //link SIGN UP
                  const Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryGreenLight,
                      fontWeight: FontWeight.bold,
                    )
                  )

                ]
              )
            )
          ],
        ),
      );
  }
}


//campul pentru email/parola
class BehanceUnderlineInput extends StatefulWidget{
  final String label;
  final IconData? rightIcon;
  final bool isPassword;

  const BehanceUnderlineInput({
    super.key,
    required this.label,
    this.rightIcon,
    this.isPassword=false
});

  //starea widget-ului
  @override
  State<BehanceUnderlineInput> createState() => _BehanceUnerlineInputState();
}

class _BehanceUnerlineInputState extends State<BehanceUnderlineInput>{
  bool _obscure = true; //pentru parola: ascuns/vizibil

  @override
  Widget build(BuildContext context){
    return TextField(
      obscureText: widget.isPassword ? _obscure:false, //ascunde textul daca e parola

      style: const TextStyle(
        color:Colors.black,
        fontSize: 16,
      ),

      decoration: InputDecoration(
        //Labelul de deasupra textului
        labelText: widget.label,
        labelStyle: const TextStyle(
          color: AppColors.primaryGreenLight,
          fontSize:14,
          fontWeight: FontWeight.w600
        ),

        //Linia gri subtire cand inputul nu este focusat
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFD3D3D3),
            width:1.2
          )
        ),

        //Linia rosie cant inputul este focusat
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryGreenLight,
            width: 1.4,
          )
        ),

        //Icon dreapta(check sau eye)
        suffixIcon: widget.isPassword ? IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600
          ),
          onPressed: (){
            setState((){
              _obscure = !_obscure;//invserseaza show/hide
            });
          },
        )
            :(widget.rightIcon!=null?Icon(
          widget.rightIcon,
          color:Colors.grey.shade600)
        :null
        ),
        contentPadding: const EdgeInsets.only(top: 6),

      ),
    );
  }

}