/*
 * Copyright 2020 Board of Trustees of the University of Illinois.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:illinois/model/Organization.dart';
import 'package:illinois/service/Analytics.dart';
import 'package:illinois/service/Onboarding.dart';
import 'package:illinois/service/Storage.dart';
import 'package:illinois/service/Styles.dart';
import 'package:illinois/ui/onboarding/OnboardingBackButton.dart';
import 'package:illinois/ui/widgets/RoleGridButton.dart';
import 'package:illinois/ui/widgets/RoundedButton.dart';

class OnboardingOrganizationsPanel extends StatefulWidget with OnboardingPanel {
  final Map<String, dynamic> onboardingContext;
  OnboardingOrganizationsPanel({this.onboardingContext});

  @override
  _OnboardingOrganizationsPanelState createState() => _OnboardingOrganizationsPanelState();

  @override
  bool get onboardingCanDisplay {
    return (Storage().organization == null);
  }
}

class _OnboardingOrganizationsPanelState extends State<OnboardingOrganizationsPanel> {

  List<Organization> _organizations;
  Organization _selectedOrganization;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _organizations = Organization.listFromJson([
      {
        "id": "uis",
        "name": "UIS",
        "icon_url": "https://upload.wikimedia.org/wikipedia/en/f/f8/UIS_Logo.png",
        "environments": {
          "production": {
            "config_url": "https://api.rokwire.illinois.edu/app/configs",
            "api_key": "00000000-0000-0000-0000-000000000000"
          },
          "dev": {
            "config_url": "https://api-dev.rokwire.illinois.edu/app/configs",
            "api_key": "00000000-0000-0000-0000-000000000000"
          },
          "test": {
            "config_url": "https://api-test.rokwire.illinois.edu/app/configs",
            "api_key": "00000000-0000-0000-0000-000000000000"
          }
        }
      },
      {
        "id": "uiuc",
        "name": "UIUC (ROKMETRO Test)",
        "icon_url": "https://upload.wikimedia.org/wikipedia/commons/7/7c/Illinois_Block_I.png",
        "environments": {
          "production": {
            "config_url": "https://api.rokwire.illinois.edu/app/configs",
            "api_key": "00000000-0000-0000-0000-000000000000"
          },
          "dev": {
            "config_url": "https://api-dev.rokwire.illinois.edu/app/configs",
            "api_key": "00000000-0000-0000-0000-000000000000"
          },
          "test": {
            "config_url": "https://api-test.rokwire.illinois.edu/app/configs",
            "api_key": "00000000-0000-0000-0000-000000000000"
          }
        }
      }
    ]);
    _selectedOrganization = Storage().organization;
  }

  @override
  Widget build(BuildContext context) {
    final double gridSpacing = 5;
    return Scaffold(
      backgroundColor: Styles().colors.background,
      body: SafeArea(child: Column( children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Row(children: <Widget>[
            OnboardingBackButton(image: 'images/chevron-left.png', padding: const EdgeInsets.only(left: 10,),
                onTap:() {
                  Analytics.instance.logSelect(target: "Back");
                  Navigator.pop(context);
                }),
            Expanded(child: Column(children: <Widget>[
              Semantics(
                label: 'Select Organization',
                hint: 'Header 1',
                excludeSemantics: true,
                child: Text('Select Organization',
                  style: TextStyle(fontFamily: Styles().fontFamilies.extraBold, fontSize: 24, color: Styles().colors.fillColorPrimary),
                ),
              ),
            ],),),
            Padding(padding: EdgeInsets.only(left: 42),),
          ],),
        ),

        Expanded(child: SingleChildScrollView(child: Padding(padding: EdgeInsets.only(left: 16, right: 8, ), child:
            Column(children: _buildOrganizations()
            ),),),),

        Padding(padding: EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 20),
          child: Stack(children:<Widget>[
            ScalableRoundedButton(
                label: _allowNext ? 'Confirm' : 'Select one',
                hint: '',
                enabled: _allowNext,
                backgroundColor: (_allowNext ? Styles().colors.white : Styles().colors.background),
                borderColor: (_allowNext
                    ? Styles().colors.fillColorSecondary
                    : Styles().colors.fillColorPrimaryTransparent03),
                textColor: (_allowNext
                    ? Styles().colors.fillColorPrimary
                    : Styles().colors.fillColorPrimaryTransparent03),
                onTap: () => _onConfirm()),
            Visibility(
              visible: _updating,
              child: Container(
                height: 48,
                child: Align(
                  alignment:Alignment.center,
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Styles().colors.fillColorPrimary),),),),),),
          ]),
        ),

      ],),),
    );
  }

  List<Widget> _buildOrganizations() {
    final double gridSpacing = 5;
    final int colCount = 2;
    List<Widget> row = <Widget>[];
    List<Widget> rows = <Widget>[];
    for (Organization organization in _organizations) {
      if (row.length == colCount) {
        rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: row));
        row = <Widget>[];
      }
      if (0 < row.length) {
        row.add(Container(height: gridSpacing,),);
      }
      row.add(Flexible(flex: 1, child: RoleGridButton(
        title: organization.name,
        hint: '',
        iconUrl: organization.iconUrl,
        selectedBackgroundColor: Styles().colors.accentColor3,
        selected: organization.id == _selectedOrganization?.id,
        data: organization,
        onTap: _onRoleGridButton,
      ),));
    }
    if (0 < row.length) {
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: row));
    }
    return rows;
  }

  bool get _allowNext {
    return (_selectedOrganization != null);
  }

  void _onRoleGridButton(RoleGridButton button) {
    if (button != null) {
      Organization organization = button.data as Organization;
      Analytics.instance.logSelect(target: "Organization: " + organization.id);

      setState(() {
        _selectedOrganization = (organization.id != _selectedOrganization?.id) ? organization : null;
      });
    }
  }

  void _onConfirm() {
    Analytics.instance.logSelect(target:"Confirm");
    if (_selectedOrganization != null && !_updating) {
      Storage().organization = _selectedOrganization;
      Onboarding().next(context, widget);
    }
  }

}


