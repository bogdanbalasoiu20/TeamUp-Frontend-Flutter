import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/utils/app_colors.dart';

class LoginScreen extends StatelessWidget{
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context){
    final size = MediaQuery.of(context).size;// afla dimnesiunea ecranului

    return Scaffold(
      resizeToAvoidBottomInset: true, //permite ridicarea UI-ului cand apare tastatura

      body: Stack(//folosesc stack pentru a pune unul peste altul fundalul,titlul, containerul si footer-ul
        children:[
          // Fundalul
          Container(
            decoration: BoxDecoration(  //clasa care imi permite sa stilizeze un container
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
                            fontSize:45,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        )
                    ),

                    SizedBox(height: 6),

                    //Subtitlu
                    Text(
                        "Sign in!",
                        style:TextStyle(
                            fontSize: 30,
                            color: Colors.white
                        )
                    )

                  ]

              )
          ),

          //Containerul alb
          Positioned(
              top: size.height*0.32,  //specific distanta fata de margini
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

                  //continutul containerului(emailOrUsername, password, buton)
                  child:SingleChildScrollView(
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

                          //Forgot password
                          Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                      fontSize:16,
                                      color: Color(0xFF2E8B57),
                                      fontWeight: FontWeight.bold
                                  )
                              )
                          ),

                          const SizedBox(height:60),

                          //Buton Sign in
                          GestureDetector(
                            //actiune la tap
                              onTap:(){}
                              ,
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
                          ),

                          const SizedBox(height:120), //spatiu pentru tastatura (Rămâne util pentru a evita suprapunerea butonului de conținutul scrollabil)
                        ],
                      )
                  )
              )
          ),

          // ⚠️ Secțiunea 'SIGN UP' a fost MUTATĂ în 'bottomNavigationBar' a Scaffold-ului
        ],
      ),

      // Soluția: Mutarea elementului fix în bottomNavigationBar pentru a NU se ridica odată cu tastatura
      bottomNavigationBar: IgnorePointer(
        ignoring: false, // permite interactiunea cu butonul (dacă ar fi un GestureDetector/InkWell)
        child: Padding(
          padding: const EdgeInsets.only(right: 26, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min, // Ocupă spațiul minim
            children: [

              Text(
                "Don't have an account?",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 6),

              //SIGN UP – ramane dedesubt, ca un link
              const Text(
                "Sign up",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2E8B57),
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---

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
            fontWeight: FontWeight.w700
        ),

        //Linia gri subtire cand inputul nu este focusat
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
                color: Color(0xFFD3D3D3),
                width:1.2
            )
        ),

        //Linia cand inputul este focusat
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

        //Spatiere intre label si linia gri + text
        contentPadding: const EdgeInsets.only(top: 18, bottom: 10),
      ),
    );
  }

}