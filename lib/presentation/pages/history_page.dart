import 'package:flutter/material.dart';
import 'package:zavod_assessment_app/presentation/components/custom_text.dart';
import 'package:zavod_assessment_app/utils/app_colors.dart';
import 'package:zavod_assessment_app/utils/gap.dart';
import 'package:zavod_assessment_app/utils/screen_utils.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Gap(20),
            ListView.builder(
              shrinkWrap: true
                ,
              itemCount: 5,
                itemBuilder: (c,i){
              return Container(
                height: 80,
                width: fullWidth(context),
                margin: EdgeInsets.only(bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                decoration: BoxDecoration(
                    color: AppColors.kWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.kbg)
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(text: 'User location: Airport road, lagos,Nigeria', fontSize:  14,fontWeight: FontWeight.bold,),
                        TextView(text: 'Marker location: Airport road, lagos,Nigeria', fontSize:  12,fontWeight: FontWeight.w700,color: AppColors.kDarkGrey,),
                        TextView(text: '10:22PM', fontSize:  12,)

                      ],
                    ),
                  ],
                ),
              );
            })


          ],
        ),
      ),
    );
  }
}
