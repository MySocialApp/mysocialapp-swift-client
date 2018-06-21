Pod::Spec.new do |s|

  s.name         = "MySocialApp"
  s.version      = "1.0.12"
  s.summary      = "Official Swift client to interact with MySocialApp API - Create your own social network app https://mysocialapp.io"

  s.description  = <<-DESC
Official Swift client to interact with apps made with MySocialApp (turnkey iOS and Android social network app builder - SaaS).

Note: This lib was made in Swift and can be used inside any Swift 3 and above apps.

Why using it?
MySocialApp is a very innovative way to have a turnkey native social network app for iOS and Android. Our API are open and ready to use for all your need inside one of our generated app or any thirds app.

What can you do?
Add social features to your existing app, automate actions, scrape contents, analyze the users content, add bot to your app, almost anything that a modern social network can bring.. There is no limit! Any suggestion to add here? Do a PR.
                   DESC

  s.homepage     = "https://mysocialapp.io"
  s.license      = { :type => "BSD", :text => <<-LICENSE
Copyright (c) 2018, MySocialApp 
All rights reserved. 

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met: 

 * Redistributions of source code must retain the above copyright notice, 
   this list of conditions and the following disclaimer. 
 * Redistributions in binary form must reproduce the above copyright 
   notice, this list of conditions and the following disclaimer in the 
   documentation and/or other materials provided with the distribution. 
 * Neither the name of MySocialApp nor the names of its contributors may be 
   used to endorse or promote products derived from this software without 
   specific prior written permission. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.
			LICENSE
 		   }


  s.author             = { "MySocialApp" => "contact@mysocialapp.io" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/MySocialApp/mysocialapp-swift-client.git", :tag => "#{s.version}" }

  s.source_files  = "MySocialApp", "MySocialApp/**/*.{h,swift}"

  s.dependency "RxSwift", "~> 3.0.1"
  s.dependency "RxCocoa", "~> 3.0.1"
  s.dependency "RxBlocking", "~> 3.0.1"
  s.dependency "Alamofire", "~> 4.0.1"

end
