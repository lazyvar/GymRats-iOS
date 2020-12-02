# GymRats iOS

[![Platform](https://img.shields.io/badge/platform-ios-lightgrey)](https://gitlab.com/gym-rats/ios-app)
[![Version](https://img.shields.io/badge/version-17-orange)](https://apps.apple.com/us/app/gymrats-group-challenge/id1453444814)
[![License](https://img.shields.io/badge/license-GPL-blue)](LICENSE)


<a href="https://apps.apple.com/us/app/gymrats-group-challenge/id1453444814"><img src=".gitlab/banner.png" width="100%"></a>

## Getting started

1. Install Xcode.
1. Clone this repository.
1. Download [cocoapods](https://cocoapods.org/) and run `pod install` to install dependencies.
1. For [unsplash](https://github.com/unsplash/unsplash-photopicker-ios) to work, make sure `UNSPLASH_ACCESS_KEY` and `UNSPLASH_SECRET_KEY` are set as environment variables.
1. Hit the big play button in Xcode.

## Dependencies

This app is grateful for and heavily dependant upon a list of [open source software](Podfile). Some highlights:
- [RxSwift](https://github.com/ReactiveX/RxSwift)
- [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [MessageKit](https://github.com/MessageKit/MessageKit)
- [SkeletonView](https://github.com/Juanpe/SkeletonView)
- [Eureka](https://github.com/xmartlabs/Eureka)
- [Feather icons](https://github.com/feathericons/feather)
- [SwiftPhoenixClient](https://github.com/davidstump/SwiftPhoenixClient)
- [YPImagePicker](https://github.com/Yummypets/YPImagePicker)

Thank you to the community!

## Inspiration

The architechecture is a flavor of MVVM as a result of learning from [Kickstarter ios-oss](https://github.com/kickstarter/ios-oss) and collaborating with [@smolster](https://github.com/smolster). It's a simplified version, without all the protocols, but it works well. One major problem left to be solved is that of global state. Luckily the app is small and there isn't a whole lot of global state to manage (a single list of challenges). Data is shared by passing structs to the view controllers that need them. By chance, it's all forward passing. For example: Challenge -> Workout -> Profile. No global state neccassary. The objects hold on to what they are given and make fresh network requests to fetch anything else.

## Known issues (tech debt)

There's some duplicated code and also some experimental abstractions I've toyed with that exist and need to be cleaned up. This project would benefit from a small amount of refactoring, but I would rather write new features.

## Contributing

Currently, there is no real process for contribution. If you'd like to see a change you can [email me](mailto:mack@gymrats.app) and I'll add it to the [backlog](https://gitlab.com/groups/gym-rats/-/boards) and get it prioritzed. This is a side project, so can't guarantee any speed. If you'd like to make a change, you can [submit a merge request](https://gitlab.com/gym-rats/ios-app/-/merge_requests/new) and I'll review it.

## License

GymRats for iOS is an open source project covered by the [GNU General Public License version 3](LICENSE).
